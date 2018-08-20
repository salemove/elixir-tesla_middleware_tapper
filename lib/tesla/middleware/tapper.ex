defmodule Tesla.Middleware.Tapper do
  @behaviour Tesla.Middleware

  @moduledoc """
  Enables distributed request tracing using Tapper

  See https://github.com/Financial-Times/tapper how to set up Tapper.

  ### Example usage
  ```
  defmodule MyClient do
    use Tesla

    plug Tesla.Middleware.Tapper
  end
  ```
  """

  def call(env, next, nil), do: call(env, next, [])

  def call(env, next, opts) do
    http_method = normalize_method(env)

    %{is_root: is_root, trace: trace} =
      start_span(
        Keyword.merge(
          opts,
          name: http_method,
          sample: true,
          annotations: [
            Tapper.http_method(http_method),
            Tapper.http_url(env.url)
          ]
        )
      )

    headers = Tapper.Plug.HeaderPropagation.encode(trace)
    env = %{env | headers: Enum.into(headers, env.headers)}

    try do
      env = Tesla.run(env, next)

      if env.status >= 500 do
        update_span(Tapper.error())
      end

      finish_span(
        %{is_root: is_root},
        annotations: [
          Tapper.client_receive(),
          Tapper.http_status_code(env.status)
        ]
      )

      env
    rescue
      ex in Tesla.Error ->
        stacktrace = System.stacktrace()

        finish_span(
          %{is_root: is_root},
          annotations: [
            Tapper.http_status_code(env.status || 0),
            Tapper.error(),
            Tapper.error_message(ex),
            Tapper.client_receive()
          ]
        )

        reraise ex, stacktrace
    end
  end

  # Starts a new trace when there is no ongoing trace, otherwise creates a
  # child span.
  defp start_span(opts) do
    if Tapper.Ctx.context?() do
      trace = Tapper.Ctx.start_span(opts)
      %{is_root: false, trace: trace}
    else
      trace = Tapper.Ctx.start(opts)
      %{is_root: true, trace: trace}
    end
  end

  defp update_span(opts) do
    Tapper.Ctx.update_span(opts)
  end

  defp finish_span(%{is_root: false}, opts) do
    Tapper.Ctx.finish_span(opts)
  end

  defp finish_span(%{is_root: true}, opts) do
    Tapper.Ctx.finish(opts)
  end

  defp normalize_method(env) do
    env.method |> to_string() |> String.upcase()
  end
end
