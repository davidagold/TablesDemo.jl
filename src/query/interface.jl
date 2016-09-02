# Satisfy column-indexable AbstractTable Query interface

AbstractTables.empty(tbl::Table) = Table()
AbstractTables.default(::Table) = Table()
