defmodule VIES do
  @moduledoc """
  VIES VAT number check.

  See https://ec.europa.eu/taxation_customs/vies/#/technical-information.
  """

  @doc """
  Validates the VAT number.

  ## Options

  You can pass any Req option, see `Req.new/1`.

  ## Examples

      iex> map = VIES.validate("PL6793108059")
      iex> map["name"]
      "INPOST SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ"

      iex> VIES.validate("PL0000000000")
      ** (RuntimeError) "PL0000000000" is invalid!

      iex> VIES.validate("PL")
      ** (RuntimeError) unexpected status 400 from VIES
      ...
  """
  def validate(number, options \\ []) do
    case request(number, options) do
      {:ok, %{body: %{"valid" => valid} = map}} ->
        if valid do
          map
        else
          raise "#{inspect(number)} is invalid!"
        end

      {:ok, resp} ->
        raise """
        unexpected status #{resp.status} from VIES

        #{inspect(resp.headers, pretty: true)}

        #{inspect(resp.body, pretty: true)}
        """

      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  Makes a request to VIES.

  Note, even if VIES returns HTTP status 200, the response can still be an error,
  one needs to check if `"valid"` field is in the response body. This is done
  by `validate/2`.

  ## Options

  You can pass any Req option, see `Req.new/1`.

  ## Examples

      iex> {:ok, resp} = VIES.request("PL6793108059")
      iex> resp.body["valid"]
      true

      iex> {:ok, resp} = VIES.request("PL0000000000")
      iex> resp.body["valid"]
      false
  """
  def request(<<letter1, letter2>> <> rest, options \\ [])
      when letter1 in ?A..?Z and letter2 in ?A..?Z do
    url = "https://ec.europa.eu/taxation_customs/vies/rest-api/check-vat-number"
    country_code = <<letter1, letter2>>

    Req.post(
      url,
      [
        json: %{
          countryCode: country_code,
          vatNumber: rest
        },
        retry: :transient
      ] ++ options
    )
  end
end
