defmodule Salemove.HttpClient.Middleware.TapperTest do
  use ExUnit.Case, async: false

  @middleware Salemove.HttpClient.Middleware.Tapper

  alias Tapper.Protocol.BinaryAnnotation

  test "successful GET request" do
    {ref, reporter} = msg_reporter()

    url = "http://example.com"
    incoming_env = %Tesla.Env{method: :get, url: url}

    action = fn env -> %{env | status: 200} end
    @middleware.call(incoming_env, [fn: action], reporter: reporter)

    assert_receive {^ref, [span]}, 1_000
    assert operation_name(span) == "GET"
    assert [:cs, :cr] = annotation_keys(span)

    assert [
             %BinaryAnnotation{key: "http.status_code", value: 200},
             %BinaryAnnotation{key: "http.url", value: ^url},
             %BinaryAnnotation{key: "http.method", value: "GET"}
           ] = binary_annotations(span)
  end

  test "successful POST request" do
    {ref, reporter} = msg_reporter()

    url = "http://example.com"
    incoming_env = %Tesla.Env{method: :post, url: url}

    action = fn env -> %{env | status: 201} end
    @middleware.call(incoming_env, [fn: action], reporter: reporter)

    assert_receive {^ref, [span]}, 1_000
    assert operation_name(span) == "POST"
    assert [:cs, :cr] = annotation_keys(span)

    assert [
             %BinaryAnnotation{key: "http.status_code", value: 201},
             %BinaryAnnotation{key: "http.url", value: ^url},
             %BinaryAnnotation{key: "http.method", value: "POST"}
           ] = binary_annotations(span)
  end

  test "server error" do
    {ref, reporter} = msg_reporter()

    url = "http://example.com"
    incoming_env = %Tesla.Env{method: :get, url: url}

    action = fn env -> %{env | status: 500} end
    @middleware.call(incoming_env, [fn: action], reporter: reporter)

    assert_receive {^ref, [span]}, 1_000
    assert operation_name(span) == "GET"
    assert [:cs, :error, :cr] = annotation_keys(span)

    assert [
             %BinaryAnnotation{key: "http.status_code", value: 500},
             %BinaryAnnotation{key: "http.url", value: ^url},
             %BinaryAnnotation{key: "http.method", value: "GET"}
           ] = binary_annotations(span)
  end

  test "connection error" do
    {ref, reporter} = msg_reporter()

    url = "http://example.com"
    incoming_env = %Tesla.Env{method: :get, url: url}

    action = fn _env ->
      raise Tesla.Error, reason: :econnrefused
    end

    assert_raise Tesla.Error, fn ->
      @middleware.call(incoming_env, [fn: action], reporter: reporter)
    end

    assert_receive {^ref, [span]}, 1_000
    assert operation_name(span) == "GET"
    assert [:cs, :error, :cr] = annotation_keys(span)

    assert [
             %BinaryAnnotation{key: :error, value: "%Tesla.Error{message: \"\", reason: :econnrefused}"},
             %BinaryAnnotation{key: "http.status_code", value: 0},
             %BinaryAnnotation{key: "http.url", value: ^url},
             %BinaryAnnotation{key: "http.method", value: "GET"}
           ] = binary_annotations(span)
  end

  defp msg_reporter() do
    self_pid = self()
    ref = make_ref()
    fun = fn term -> send(self_pid, {ref, term}) end
    {ref, fun}
  end

  defp annotation_keys(%{annotations: annotations} = _span) do
    annotations
    |> Enum.sort_by(fn annotation -> Map.get(annotation, :duration) end)
    |> Enum.reverse()
    |> Enum.map(fn annotation -> Map.get(annotation, :value) end)
  end

  defp operation_name(%{name: name} = _span), do: name

  defp binary_annotations(%{binary_annotations: binary_annotations} = _span) do
    binary_annotations
  end
end
