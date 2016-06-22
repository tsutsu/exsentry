defmodule ExSentry.Model.StacktraceTest do
  use ExSpec, async: true
  doctest ExSentry.Model.Stacktrace

  @stacktrace [
    {:erl_internal, :op_type, [:get_stacktrace, 0], [file: 'erl_internal.erl', line: 212]},
    {:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 309]},
    {:elixir_translator, :translate, 2, []},
    {:elixir_translator, :translate_arg, 3, [file: 'src/elixir_translator.erl', line: 349]},
    {:lists, :mapfoldl, 3, [line: 1353]},
    {:elixir_translator, :translate, 2, [file: 'src/elixir_translator.erl', line: 263]},
    {:elixir, :quoted_to_erl, 3, [file: 'src/elixir.erl', line: 228]},
    {:elixir, :eval_forms, 4, [file: 'src/elixir.erl']}
  ]

  @fst %ExSentry.Model.Stacktrace{frames: [
    %{filename: "erl_internal.erl", function: "op_type/2", lineno: 212, module: :erl_internal},
    %{filename: "src/elixir_translator.erl", function: "guard_op/2", lineno: 309, module: :elixir_translator},
    %{module: :elixir_translator, function: "translate/2"},
    %{filename: "src/elixir_translator.erl", function: "translate_arg/3", lineno: 349, module: :elixir_translator},
    %{function: "mapfoldl/3", lineno: 1353, module: :lists},
    %{filename: "src/elixir_translator.erl", function: "translate/2", lineno: 263, module: :elixir_translator},
    %{filename: "src/elixir.erl", function: "quoted_to_erl/3", lineno: 228, module: :elixir},
    %{filename: "src/elixir.erl", function: "eval_forms/4", module: :elixir},
  ]}

  ExSpec.describe "from_stacktrace" do
    it "formats stacktrace correctly" do
      fst = ExSentry.Model.Stacktrace.from_stacktrace(@stacktrace)
      assert(@fst == fst)
    end
  end

  ExSpec.describe "serialization" do
    it "serializes to JSON" do
      fst = ExSentry.Model.Stacktrace.from_stacktrace(@stacktrace)
      assert({:ok, _} = fst |> Poison.encode)
    end
  end
end

