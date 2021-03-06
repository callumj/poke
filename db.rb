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
  Bignum        :statement_hash
  String        :collected_from

  String        :user
  String        :host

  index :execution_time
  index :lock_time
  index :collected_from
  index :statement_hash
  index :occurred_at
end

Poke.system_db.create_table? :query_executions do
  primary_key   :id

  Fixnum        :query_id
  Fixnum        :order

  String        :select_method
  Bignum        :select_method_hash

  String        :join_method
  Bignum        :join_method_hash

  String        :index_method
  Bignum        :index_method_hash

  String        :table

  String        :possible_indexes_serialized

  String        :selected_index
  Bignum        :selected_index_hash

  Fixnum        :index_length_used
  Fixnum        :rows_examined

  index :select_method_hash
  index :index_method_hash
  index :selected_index_hash
  index :join_method_hash
  index :query_id
end

Poke.system_db.create_table? :query_execution_events do
  Fixnum :query_execution_id
  Fixnum :execution_event_id

  primary_key [:query_execution_id, :execution_event_id]
end

Poke.system_db.create_table? :execution_events do
  Bignum  :name_hash, primary_key: true
  String  :name
end

Poke.system_db.create_table? :configs do
  String        :key, length: 64, primary_key: true
  String        :value
end
