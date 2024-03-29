defmodule LiveCalendarWeb.Pagination do
  @moduledoc """
  Pagination component
  """
  use Phoenix.Component

  @display_buttons 5

  @doc """
  Renders the pagination component
  """
  attr :total, :integer, required: true
  attr :page, :integer, required: true
  attr :per_page, :integer, required: true
  attr :click_next, :string, required: true
  attr :click_prev, :string, required: true
  attr :click_number, :string, required: true

  def pagination(%{total: total, per_page: per_page} = assigns) do
    assigns = assign(assigns, total_pages: ceil(total / per_page))

    ~H"""
    <nav
      class="flex flex-col md:flex-row justify-between items-start md:items-center space-y-3 md:space-y-0 p-4"
      aria-label="Table navigation"
    >
      <span class="text-sm font-normal text-gray-500 dark:text-gray-400">
        Showing
        <span class="font-semibold text-gray-900 dark:text-white"><%= showing(assigns) %></span>
        of <span class="font-semibold text-gray-900 dark:text-white"><%= @total %></span>
      </span>
      <ul class="inline-flex items-stretch -space-x-px">
        <li>
          <a
            phx-click={@click_prev}
            class="flex items-center justify-center h-full py-1.5 px-3 ml-0 text-gray-500 bg-white rounded-l-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
          >
            <span class="sr-only">Previous</span>
            <svg
              class="w-5 h-5"
              aria-hidden="true"
              fill="currentColor"
              viewbox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                clip-rule="evenodd"
              />
            </svg>
          </a>
        </li>
        <li :for={page <- buttons(assigns)}>
          <a
            phx-click={@click_number}
            phx-value-page={page}
            class={[
              if page == @page do
                "flex items-center justify-center text-sm z-10 py-2 px-3 leading-tight text-primary-600 bg-primary-50 border border-primary-300 hover:bg-primary-100 hover:text-primary-700 dark:border-gray-700 dark:bg-gray-700 dark:text-white"
              else
                "flex items-center justify-center text-sm py-2 px-3 leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
              end
            ]}
          >
            <%= page %>
          </a>
        </li>

        <li>
          <a
            href="#"
            class="flex items-center justify-center text-sm py-2 px-3 leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
          >
            ...
          </a>
        </li>
        <li>
          <a
            phx-click={@click_number}
            phx-value-page={@total_pages}
            class="flex items-center justify-center text-sm py-2 px-3 leading-tight text-gray-500 bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
          >
            <%= @total_pages %>
          </a>
        </li>
        <li>
          <a
            phx-click={@click_next}
            class="flex items-center justify-center h-full py-1.5 px-3 leading-tight text-gray-500 bg-white rounded-r-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
          >
            <span class="sr-only">Next</span>
            <svg
              class="w-5 h-5"
              aria-hidden="true"
              fill="currentColor"
              viewbox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z"
                clip-rule="evenodd"
              />
            </svg>
          </a>
        </li>
      </ul>
    </nav>
    """
  end

  defp showing(%{page: page, per_page: per_page, total: total}) do
    from = (page - 1) * per_page + 1
    to = Enum.min([page * per_page, total])

    "#{from} - #{to}"
  end

  defp buttons(%{page: page, total_pages: total_pages}) do
    from = max(1, page - div(@display_buttons, 2))
    to = min(total_pages, page + div(@display_buttons, 2))
    Enum.take(from..to, @display_buttons)
  end
end
