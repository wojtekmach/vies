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
    case check(number, options) do
      {:ok, map} ->
        if map["valid"] do
          map
        else
          raise "#{inspect(number)} is invalid!"
        end

      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  Checks the VAT number.

  Returns information about the VAT number, even if it's invalid.

  ## Options

  You can pass any Req option, see `Req.new/1`.

  ## Examples

      iex> {:ok, map} = VIES.check("PL6793108059")
      iex> map["valid"]
      true

      iex> {:ok, map} = VIES.check("PL0000000000")
      iex> map["valid"]
      false
  """
  def check(number, options \\ []) do
    case request(number, options) do
      {:ok, %{status: 200, body: %{"valid" => _} = body}} ->
        {:ok, body}

      {:ok, resp} ->
        exception =
          RuntimeError.exception("""
          unexpected status #{resp.status} from VIES

          #{inspect(resp.headers, pretty: true)}

          #{inspect(resp.body, pretty: true)}
          """)

        {:error, exception}

      {:error, _} = error ->
        error
    end
  end

  @doc false
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
