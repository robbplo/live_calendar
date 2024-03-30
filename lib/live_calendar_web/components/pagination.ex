defmodule LiveCalendarWeb.Pagination do
  @moduledoc """
  Pagination component
  """
  use Phoenix.Component

  @doc """
  Renders the pagination component
  """
  attr :total, :integer, required: true
  attr :page, :integer, required: true
  attr :per_page, :integer, default: 10
  attr :display_buttons, :integer, default: 5
  attr :set_page, :string, default: "set_page"

  def pagination(%{total: total, per_page: per_page} = assigns) do
    assigns = assign(assigns, total_pages: ceil(total / per_page))
    assigns = assign(assigns, buttons: buttons(assigns))

    ~H"""
    <nav
      class="flex flex-col md:flex-row justify-between items-start md:items-center space-y-3
      md:space-y-0 p-4"
      aria-label="Table navigation"
    >
      <span class="text-sm font-normal text-gray-500 dark:text-gray-400">
        Showing
        <span class="font-semibold text-gray-900 dark:text-white"><%= showing(assigns) %></span>
        of <span class="font-semibold text-gray-900 dark:text-white"><%= @total %></span>
      </span>
      <ul class="inline-flex items-stretch -space-x-px select-none">
        <li>
          <a
            phx-click={@page > 1 && @set_page}
            phx-value-page={@page - 1}
            class="flex items-center justify-center h-full py-1.5 px-3 ml-0 text-gray-500 bg-white
            rounded-l-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700
            dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700
            dark:hover:text-white"
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
                d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414
            1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z"
                clip-rule="evenodd"
              />
            </svg>
          </a>
        </li>

        <%= if 1 not in @buttons do %>
          <li>
            <a
              phx-click={@set_page}
              phx-value-page={1}
              class="flex items-center justify-center text-sm py-2 px-3 leading-tight text-gray-500
            bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800
            dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white
            cursor-pointer"
            >
              1
            </a>
          </li>
          <li>
            <span class="flex items-center justify-center text-sm py-2 px-3 leading-tight
          text-gray-500 bg-white border border-gray-300 dark:bg-gray-800 dark:border-gray-700
          dark:text-gray-400">
              ...
            </span>
          </li>
        <% end %>

        <li :for={page <- @buttons}>
          <a
            phx-click={@set_page}
            phx-value-page={page}
            class={[
              "flex items-center justify-center text-sm py-2 px-3 leading-tight border",
              if page == @page do
                "relative z-10 text-primary-600 bg-primary-50 border-primary-300
                hover:bg-primary-100 hover:text-primary-700 dark:border-gray-700 dark:bg-gray-700
                dark:text-white"
              else
                "text-gray-500 bg-white border-gray-300 hover:bg-gray-100 hover:text-gray-700
                dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700
                dark:hover:text-white cursor-pointer"
              end
            ]}
          >
            <%= page %>
          </a>
        </li>

        <% show_end = @total_pages not in @buttons %>
        <li :if={show_end}>
          <span class="flex items-center justify-center text-sm py-2 px-3 leading-tight
            text-gray-500 bg-white border border-gray-300 dark:bg-gray-800 dark:border-gray-700
            dark:text-gray-400 ">
            ...
          </span>
        </li>

        <li :if={show_end}>
          <a
            phx-click={@set_page}
            phx-value-page={@total_pages}
            class="flex items-center justify-center text-sm py-2 px-3 leading-tight text-gray-500
            bg-white border border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800
            dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white
            cursor-pointer"
          >
            <%= @total_pages %>
          </a>
        </li>

        <li>
          <a
            phx-click={@page < @total_pages && @set_page}
            phx-value-page={@page + 1}
            class="flex items-center justify-center h-full py-1.5 px-3 leading-tight text-gray-500
              bg-white rounded-r-lg border border-gray-300 hover:bg-gray-100 hover:text-gray-700
              dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700
              dark:hover:text-white cursor-pointer"
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
                d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010
            1.414l-4 4a1 1 0 01-1.414 0z"
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

  defp buttons(%{page: page, total_pages: total_pages, display_buttons: display_buttons}) do
    from = max(1, page - div(display_buttons, 2))
    to = min(total_pages, page + div(display_buttons, 2))
    Enum.take(from..to, display_buttons)
  end
end
