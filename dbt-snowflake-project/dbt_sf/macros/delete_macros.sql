merge into silver_table tgt
using src_stream s
  on tgt.id = s.id
when matched and s.metadata$action = 'DELETE' and s.metadata$isupdate = false
  then update set is_deleted = true, deleted_at = current_timestamp();