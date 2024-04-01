defmodule LiveCalendarWeb.LiveTable do
  @moduledoc false
  use LiveCalendarWeb, :live_component

  import Ecto.Query
  import LiveCalendarWeb.Pagination

  alias LiveCalendar.Repo

  def render(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 relative shadow-md sm:rounded-lg overflow-hidden">
      <.flash_group flash={@flash} />
      <form id="selection" class="hidden"></form>
      <div class="flex flex-col md:flex-row items-center justify-between space-y-3 md:space-y-0 md:space-x-4 p-4">
        <div class="w-full md:w-1/2">
          <form class="flex items-center">
            <label for="simple-search" class="sr-only">Search</label>
            <div class="relative w-full">
              <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                <svg
                  aria-hidden="true"
                  class="w-5 h-5 text-gray-500 dark:text-gray-400"
                  fill="currentColor"
                  viewbox="0 0 20 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fill-rule="evenodd"
                    d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    clip-rule="evenodd"
                  />
                </svg>
              </div>
              <.input
                type="date"
                name="date"
                value=""
                class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full pl-10 p-2 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
                phx-change="search"
                phx-debounce="300"
                phx-target={@myself}
              />
            </div>
          </form>
        </div>
        <div class="w-full md:w-auto flex flex-col md:flex-row space-y-2 md:space-y-0 items-stretch
          md:items-center justify-end md:space-x-3 flex-shrink-0 relative">
          <button
            type="button"
            class="flex items-center justify-center text-white bg-primary-700 hover:bg-primary-800 focus:ring-4 focus:ring-primary-300 font-medium rounded-lg text-sm px-4 py-2 dark:bg-primary-600 dark:hover:bg-primary-700 focus:outline-none dark:focus:ring-primary-800"
          >
            <svg
              class="h-3.5 w-3.5 mr-2"
              fill="currentColor"
              viewbox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
              aria-hidden="true"
            >
              <path
                clip-rule="evenodd"
                fill-rule="evenodd"
                d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
              />
            </svg>
            Add product
          </button>
          <.dropdown :if={length(@selected) > 0}>
            <div class="py-1">
              <a
                class="block py-2 px-4 text-sm text-gray-700 hover:bg-gray-100 dark:hover:bg-gray-600 dark:text-gray-200 dark:hover:text-white"
                phx-click="delete_selected"
                phx-target={@myself}
              >
                Delete selected
              </a>
            </div>
          </.dropdown>
        </div>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
          <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
              <th scope="col" class="px-4 py-3">
                <input
                  type="checkbox"
                  form="selection"
                  name="select_page"
                  phx-change="select_page"
                  phx-target={@myself}
                  checked={Enum.count(@selected) == length(@results)}
                />
              </th>
              <th :for={col <- @col} scope="col" class="px-4 py-3"><%= col[:title] %></th>
              <th scope="col" class="px-4 py-3"><span class="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            <tr :for={row <- @results} class="border-b dark:border-gray-700">
              <td class="px-4 py-3">
                <input
                  type="checkbox"
                  form="selection"
                  name="selected[]"
                  id={"selection-#{row.id}"}
                  phx-click="select"
                  phx-value-id={row.id}
                  phx-target={@myself}
                  phx-hook="DetectShift"
                  checked={Enum.member?(@selected, row.id)}
                />
              </td>
              <td :for={col <- @col} class="px-4 py-3"><%= render_slot(col, row) %></td>
              <td class="px-4 py-3 flex items-center justify-end">
                <button
                  type="button"
                  class="text-gray-400 hover:text-gray-600 dark:text-gray-300 dark:hover:text-gray-200"
                  phx-click="delete"
                  phx-value-id={row.id}
                  phx-target={@myself}
                >
                  <.icon name="hero-trash" class="" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <.pagination total={@total} per_page={@per_page} page={@page} target={@myself} />
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, page: 1, per_page: 10, results: [], total: 0, selected: [], last_selected: nil)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> fetch_results()}
  end

  def handle_event("select_page", assigns, socket) do
    selected =
      case assigns["select_page"] do
        "on" -> Enum.map(socket.assigns.results, & &1.id)
        _ -> []
      end

    {:noreply, assign(socket, selected: selected)}
  end

  def handle_event("select", assigns, socket) do
    {:noreply, handle_select(socket, assigns)}
  end

  def handle_event("set_page", %{"page" => page}, socket) do
    {:noreply, socket |> assign(page: String.to_integer(page)) |> fetch_results()}
  end

  def handle_event("search", %{"date" => date}, socket) do
    {:noreply, socket |> assign(date: date) |> fetch_results()}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    with %{} = record <- Enum.find(socket.assigns.results, &(&1.id == String.to_integer(id))),
         {:ok, _} <- Repo.delete(record) do
      {:noreply, fetch_results(socket)}
    else
      nil -> {:noreply, put_flash(socket, :error, "Record not found")}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to delete record")}
    end
  end

  def handle_event("delete_selected", _, socket) do
    case Repo.delete_all(from(r in socket.assigns.schema, where: r.id in ^socket.assigns.selected)) do
      {_deleted, nil} -> {:noreply, socket |> fetch_results() |> assign(selected: [])}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Failed to delete records")}
    end
  end

  defp fetch_results(socket) do
    offset = (socket.assigns.page - 1) * socket.assigns.per_page
    query = from(socket.assigns.schema)

    query =
      case socket.assigns[:date] do
        nil -> query
        date -> where(query, date: ^date)
      end

    results =
      query
      |> limit(^socket.assigns.per_page)
      |> offset(^offset)
      |> Repo.all()

    total = Repo.aggregate(query, :count, :id)
    assign(socket, results: results, total: total)
  end

  defp handle_select(socket, assigns) do
    id = String.to_integer(assigns["id"])

    diff =
      case {socket.assigns.last_selected, assigns["shift-pressed"]} do
        {previous, "true"} when is_integer(previous) -> Enum.to_list(previous..id)
        _ -> [id]
      end

    new_selection =
      case assigns["value"] do
        "on" -> Enum.uniq(socket.assigns.selected ++ diff)
        _ -> Enum.uniq(socket.assigns.selected -- diff)
      end

    socket
    |> assign(selected: new_selection)
    |> assign(last_selected: id)
  end
end
