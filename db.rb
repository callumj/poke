Poke.system_db.create_table? :queries do
  primary_key   :id
  Time          :occurred_at
  Float         :execution_time
  Float         :lock_time
  Fixnum        :rows_sent
  Fixnum        :rows_examined
  String        :schema
  Fixnum        :last_insert_id
  Fixnum        :insert_id
  Fixnum        :server_id
  String        :statement,       text: true
  Fixnum        :statement_hash
  String        :collected_from

  String        :user
  String        :host

  index :execution_time
  index :lock_time
  index :collected_from
  index :statement_hash
  index :occurred_at
end

Poke.system_db.create_table? :configs do
  String        :key, length: 64, primary_key: true
  String        :value
end
