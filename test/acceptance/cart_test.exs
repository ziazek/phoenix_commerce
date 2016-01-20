defmodule PhoenixCommerce.Acceptance.CartTest do
  use ExUnit.Case
  use Hound.Helpers
  hound_session
  alias PhoenixCommerce.Product
  alias PhoenixCommerce.Repo

  @upload %Plug.Upload{path: Path.relative_to_cwd("test/files/broom.jpg"), filename: "broom.jpg", content_type: "image/jpg"}

  setup do
    Repo.delete_all(Product)
    {:ok, product} =
      Product.changeset(%Product{}, %{
        name: "Some product",
        description: "Some product description",
        price: Decimal.new("25.20"),
        image: @upload
      }) |> Repo.insert
    {:ok, product: product}
  end

  test "/cart shows empty cart" do
    navigate_to "/cart"
    assert visible_text(heading) == "Your cart"
    assert length(line_items) == 0
  end

  test "adding product to cart shows product in cart", %{product: product} do
    navigate_to "/products/#{product.id}"
    add_to_cart_button = find_element(:css, "button.add-to-cart")
    click(add_to_cart_button)
    navigate_to "/cart"
    assert length(line_items) == 1
    assert visible_text(hd(line_items)) =~ ~r/#{product.name}/
  end

  def heading, do: find_element(:css, "h2")

  def cart, do: find_element(:css, ".cart")

  def cart_table, do: find_within_element(cart, :css, "table")

  def cart_tbody, do: find_within_element(cart_table, :css, "tbody")

  def line_items, do: find_all_within_element(cart_tbody, :css, "tr")
end
