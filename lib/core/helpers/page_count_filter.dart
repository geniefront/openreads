bool matchesPageLimit(int? pages, bool shortBooksOnly) =>
    !shortBooksOnly || (pages != null && pages > 0 && pages <= 200);