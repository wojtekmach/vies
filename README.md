# VIES

VIES VAT number check library using Req.

## Usage

```elixir
iex> Mix.install([{:vies, github: "wojtekmach/vies"}])

iex> VIES.check("PL6793108059")
{:ok, %{"valid" => true, ...}}

iex> VIES.check("PL0000000000")
{:ok, %{"valid" => false, ...}}

iex> VIES.validate("PL6793108059")
%{"valid" => true, ...}

iex> VIES.validate("PL0000000000")
** (RuntimeError) "PL0000000000" is invalid!
```

## License

Copyright (c) 2025 Wojtek Mach

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
