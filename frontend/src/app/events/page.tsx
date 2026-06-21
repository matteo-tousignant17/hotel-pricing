import type { Event } from "@/lib/types";
import { getServerClient } from "@/lib/supabase-server";

const IMPACT_STYLES: Record<string, string> = {
  citywide: "bg-purple-100 text-purple-800",
  high: "bg-red-100 text-red-800",
  medium: "bg-amber-100 text-amber-800",
  low: "bg-gray-100 text-gray-600",
};

const TYPE_ICONS: Record<string, string> = {
  sports: "🏈",
  convention: "🏢",
  festival: "🍺",
  holiday: "🎉",
  concert: "🎵",
};

export default async function EventsPage() {
  let events: Event[] = [];
  let error: string | null = null;

  try {
    const supabase = getServerClient();
    const { data, error: dbError } = await supabase
      .from("events")
      .select("*")
      .order("start_date");

    if (dbError) throw dbError;
    events = (data ?? []) as Event[];
  } catch {
    error = "Could not load events — check your Supabase connection.";
  }

  const grouped = events.reduce<Record<string, Event[]>>((acc, e) => {
    const month = new Date(e.start_date + "T00:00:00").toLocaleDateString("en-US", {
      month: "long",
      year: "numeric",
    });
    if (!acc[month]) acc[month] = [];
    acc[month].push(e);
    return acc;
  }, {});

  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl font-bold">Denver Event Calendar</h1>
        <p className="mt-1 text-sm text-gray-500">
          {events.length} events driving demand shifts across the market
        </p>
      </div>

      {error && (
        <div className="mb-6 rounded-lg border border-red-200 bg-red-50 p-4 text-red-700">
          {error}
        </div>
      )}

      <div className="space-y-8">
        {Object.entries(grouped).map(([month, monthEvents]) => (
          <div key={month}>
            <h2 className="mb-3 text-sm font-semibold uppercase tracking-wider text-gray-500">
              {month}
            </h2>
            <div className="space-y-2">
              {monthEvents.map((event) => (
                <div
                  key={event.id}
                  className="flex items-start gap-4 rounded-xl border border-gray-200 bg-white p-4"
                >
                  <span className="mt-0.5 text-xl">
                    {TYPE_ICONS[event.event_type] ?? "📅"}
                  </span>
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="font-medium">{event.name}</span>
                      <span
                        className={`rounded-full px-2 py-0.5 text-xs font-medium capitalize ${IMPACT_STYLES[event.demand_impact]}`}
                      >
                        {event.demand_impact} impact
                      </span>
                    </div>
                    <div className="mt-1 text-sm text-gray-500">
                      {new Date(event.start_date + "T00:00:00").toLocaleDateString("en-US", {
                        month: "short",
                        day: "numeric",
                      })}
                      {event.end_date !== event.start_date &&
                        ` – ${new Date(event.end_date + "T00:00:00").toLocaleDateString("en-US", { month: "short", day: "numeric" })}`}
                      {event.venue && ` · ${event.venue}`}
                      {event.estimated_attendance && (
                        <span className="text-gray-400">
                          {" "}
                          · {event.estimated_attendance.toLocaleString()} attendees
                        </span>
                      )}
                    </div>
                    {event.affected_neighborhoods && (
                      <div className="mt-1.5 flex flex-wrap gap-1">
                        {event.affected_neighborhoods.map((n) => (
                          <span
                            key={n}
                            className="rounded bg-gray-100 px-1.5 py-0.5 text-xs text-gray-600"
                          >
                            {n}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
