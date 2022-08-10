defmodule Cldr.Trans.Article.Translations.Fields do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :title, :string
    field :body, :string
  end

  def changeset(fields, params) do
    fields
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end
end

defmodule Cldr.Trans.Article do
  @moduledoc """
  Example schema using embedded structs for translations.

  Since the translation container field `translations` is only declared once, we define the
  embedded schema inline. The translation fields are repeated for each translatable language,
  so we extract this embedded schema to its own module.

  Embedded schemas are much more explicit about how everything works and provide higher flexibility
  in validations and transformations by using their own changesets. Using embedded schemas also
  makes it easier to build forms thanks to the [Phoenix.HTML.Form.inputs_for/2](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Form.html#module-nested-inputs) helper.

  Due to this reasons, **embedded schemas are the preferred way of using Trans.**
  """

  use Ecto.Schema
  use Cldr.Trans, translates: [:title, :body]

  import Ecto.Changeset

  schema "articles" do
    field :title, :string
    field :body, :string
    has_many :comments, Cldr.Trans.Comment

    embeds_one :translations, Translations, on_replace: :update, primary_key: false do
      embeds_one :es, __MODULE__.Fields, on_replace: :update
      embeds_one :fr, __MODULE__.Fields, on_replace: :update
    end
  end

  def changeset(article, params \\ %{}) do
    article
    |> cast(params, [:title, :body])
    |> cast_embed(:translations, with: &translations_changeset/2)
    |> validate_required([:title, :body])
  end

  defp translations_changeset(translations, params) do
    translations
    |> cast(params, [])
    |> cast_embed(:es)
    |> cast_embed(:fr)
  end
end

