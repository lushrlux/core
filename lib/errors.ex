defmodule LushrLux.Core.Errors do
  import Ecto.Changeset

  @moduledoc """
  To make all the endpoints in a file more readable some of the error formatting has been moved here.
  """

  @doc """
  This might not be the most elegant solution but it works for what it needs to do. Returning a status code and
  an error message which is done dynamically.

  * It takes the changeset from ecto when it fails. It taverse it to find the error section.
  * From that error section it finds the fields.
  * From the same error section it finds the message.

  As from my experience ecto changesets only happen as one _event_ i.e. you're either going to get say a conflict
  error on a `unique_constrait` or you're going to be missing required fields. It then looks at the error message
  and pattern matches on the error message and the appropriate http status code for that error is returned along
  with the generated message based on the fields that were either say, conflicting, or missing.
  """
  def read_errors(changeset) do
    decoded = changeset |> decode_errors()
    fields = error_keys(decoded)
    msg = error_messages(decoded)

    case msg do
      "can't be blank" -> {400, "Missing fields #{fields}"}
      "has already been taken" -> {409, "That #{fields} already exists"}
    end
  end

  defp decode_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp error_keys(decoded_errors) do
    decoded_errors
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
    |> Enum.map(fn m -> String.replace(m, "_", " ") end)
    |> Enum.join(", ")
  end

  defp error_messages(decoded_errors) do
    decoded_errors
    |> Map.values()
    |> List.flatten()
    |> List.first()
  end
end
