defmodule LeanCoffee.ValidInputs do
  alias Phoenix.HTML.Form

  def password_input(form, field, opts \\ []) do
    Form.password_input(form, field, opts ++ Form.input_validations(form, field))
  end

  def text_input(form, field, opts \\ []) do
    Form.text_input(form, field, extend_opts(form, field, opts))
  end

  defp extend_opts(form, field, opts) do
    defaults = opts ++ Form.input_validations(form, field)
    case form.source.validations[field] do
      {:format, regex} -> [{:pattern, Regex.source(regex)} | defaults]
      _ -> defaults
    end
  end

  def number_input(form, field, opts \\ []) do
    Form.number_input(form, field, opts ++ Form.input_validations(form, field))
  end
end
