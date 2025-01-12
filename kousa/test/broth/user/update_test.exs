defmodule BrothTest.User.UpdateTest do
  use ExUnit.Case, async: true
  use KousaTest.Support.EctoSandbox

  alias Beef.Schemas.User
  alias Beef.Users
  alias BrothTest.WsClient
  alias BrothTest.WsClientFactory
  alias KousaTest.Support.Factory

  require WsClient

  setup do
    user = Factory.create(User)
    client_ws = WsClientFactory.create_client_for(user)

    {:ok, user: user, client_ws: client_ws}
  end

  describe "the websocket user:update operation" do
    test "a username can be changed", t do
      user_id = t.user.id

      ref =
        WsClient.send_call(
          t.client_ws,
          "user:update",
          %{
            "username" => "new_username"
          }
        )

      WsClient.assert_reply(
        "user:update:reply",
        ref,
        %{
          "username" => "new_username"
        }
      )

      assert Users.get_by_id(user_id).username == "new_username"
    end

    test "username taken", t do
      %{username: existing_username} = Factory.create(User)

      ref =
        WsClient.send_call(
          t.client_ws,
          "user:update",
          %{
            "username" => existing_username
          }
        )

      WsClient.assert_reply(
        "user:update:reply",
        ref,
        %{
          "isUsernameTaken" => true
        }
      )
    end

    test "a bio,displayName,avatarUrl can be changed", t do
      user_id = t.user.id

      ref =
        WsClient.send_call(
          t.client_ws,
          "user:update",
          %{
            "bio" => "hi",
            "displayName" => "test",
            "avatarUrl" =>
              "https://pbs.twimg.com/profile_images/1152793238761345024/VRBvxeCM_400x400.jpg"
          }
        )

      WsClient.assert_reply(
        "user:update:reply",
        ref,
        %{
          "bio" => "hi",
          "displayName" => "test",
          "avatarUrl" =>
            "https://pbs.twimg.com/profile_images/1152793238761345024/VRBvxeCM_400x400.jpg"
        }
      )

      user = Users.get_by_id(user_id)

      assert user.bio == "hi"
      assert user.displayName == "test"

      assert user.avatarUrl ==
               "https://pbs.twimg.com/profile_images/1152793238761345024/VRBvxeCM_400x400.jpg"
    end

    @tag :skip
    test "bad usernames"

    @tag :skip
    test "other fields"
  end
end
