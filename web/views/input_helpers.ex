defmodule LeanCoffee.InputHelpers do
  use Phoenix.HTML
  alias Phoenix.HTML.Form

  @client_validation Application.get_env(:lean_coffee, :client_validation, :on)

  def input(form, field, opts \\ []) do
    type = opts[:using] || Form.input_type(form, field)

    wrapper_opts = [class: "form-group #{state_class(form, field)}"]
    label_opts = [class: "control-label"]
    input_opts = input_validations(form, field, [class: "form-control"])

    content_tag :div, wrapper_opts do
      label = label(form, field, humanize(field), label_opts)
      input = apply(Form, type, [form, field, input_opts])
      error = LeanCoffee.ErrorHelpers.error_tag(form, field)
      [label, input, error || ""]
    end
  end

  defp state_class(form, field) do
    cond do
      !form.source.action -> ""
      form.errors[field] -> "has-error"
      true -> "has-success"
    end
  end

  defp input_validations(form, field, opts) do
    input_validations(@client_validation, form, field, opts)
  end
  defp input_validations(:on, form, field, opts) do
    default_validations = Form.input_validations(form, field)
    default = Keyword.merge(default_validations, opts)
    validations = Map.get(form.source, :validations, %{})
    case validations[field] do
      {:format, regex} -> [{:pattern, Regex.source(regex)} | default]
      _ -> default
    end
  end
  defp input_validations(_, _form, _field, opts) do
    opts
  end
end
