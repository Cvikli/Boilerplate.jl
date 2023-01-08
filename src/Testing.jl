module Testing

db = nothing
set_db(d) = begin
  # ONLY allow worker 1 to store global variables.
  myid() == 1 && (global db = d)
  nothing
end
get_db() = db

log_db = Any[]
append_logdb(d) = begin
  global log_db
  push!(log_db, d)
  nothing
end
reset_logmem() = global log_db = Any[]
get_logdb() = log_db

end