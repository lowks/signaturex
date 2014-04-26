defmodule SignaturexTest do
  use ExUnit.Case
  alias Signaturex.Time
  import Signaturex
  import :meck

  defp hash_with_string_keys(hash) do
    Enum.map(hash, fn { k, v } -> { to_string(k), v } end)
  end

  setup do
    new Time
    expect(Time, :stamp, 0, 1234)
  end

  teardown do
    unload Time
  end

  test "sign with string method" do
    signed_params = sign("key", "secret", "post",
                         "/some/path", [query: "params", go: "here"])
                      |> Dict.to_list

    assert signed_params == [{"auth_version", "1.0"}, {"auth_key", "key"}, {"auth_signature", "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db"}, {"auth_timestamp", 1234}]

    assert validate Time
  end

  test "sign with atom method" do
    signed_params = sign("key", "secret", :post,
                         "/some/path", [query: "params", go: "here"])
                      |> Dict.to_list

    assert signed_params == [{"auth_version", "1.0"}, {"auth_key", "key"}, {"auth_signature", "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db"}, {"auth_timestamp", 1234}]

    assert validate Time
  end

  test "sign with query params with capitalised letters" do
    signed_params = sign("key", "secret", "post",
                         "/some/path", [ { "Query", "params" },
                                         { "Go", "here" }])
                      |> Dict.to_list

    assert signed_params == [{"auth_version", "1.0"}, {"auth_key", "key"}, {"auth_signature", "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db"}, {"auth_timestamp", 1234}]

    assert validate Time
  end

  test "validate signature" do
    params = [ auth_signature: "3b237953a5ba6619875cbb2a2d43e8da9ef5824e8a2c689f6284ac85bc1ea0db",
               auth_key: "key", auth_timestamp: "1234", auth_version: "1.0",
               query: "params", go: "here" ] |> hash_with_string_keys

    assert validate!("key", "secret", "post", "/some/path", params) == true
  end
end
