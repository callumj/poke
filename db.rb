Poke.system_db.create_table :slow_queries do
  primary_key   :id
  Time          :occurred_at
  Fixnum        :execution_time
  Fixnum        :lock_time
  Fixnum        :rows_sent
  Fixnum        :rows_examined
  String        :schema
  Fixnum        :last_insert_id
  Fixnum        :insert_id
  Fixnum        :server_id
  String        :statement,       text: true
  String        :statement_hash,  length: 64
  String        :occurrence_hash, length: 64
end
