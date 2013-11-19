Poke.system_db.create_table? :queries do
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
  Fixnum        :statement_hash
  String        :collected_from

  String        :user
  String        :host

  index :execution_time
  index :lock_time
  index :collected_from
  index :statement_hash
end

Poke.system_db.create_table? :configs do
  String        :key, length: 64
  String        :value

  primary_key :key
end

{:start_time=>2013-10-03 13:37:06 +0800,
 :user_host=>"connectedfm[connectedfm] @  [10.10.24.242]",
 :query_time=>2000-01-01 00:00:11 +0800,
 :lock_time=>2000-01-01 00:00:00 +0800,
 :rows_sent=>1,
 :rows_examined=>1771354,
 :db=>"connectedfm_production",
 :last_insert_id=>0,
 :insert_id=>0,
 :server_id=>43013862,
 :sql_text=>
  "SELECT  `stories`.* FROM `stories` INNER JOIN `activity_stories` ON `activity_stories`.`story_id` = `stories`.`id` INNER JOIN `activities` ON `activities`.`id` = `activity_stories`.`activity_id` WHERE `stories`.`target_id` = 2831 AND `stories`.`target_type` = 'User' AND `stories`.`target_disposition` = 'connection' AND `stories`.`type` = 'ArtistPostStory' AND `activities`.`subject_type` = 'Post' AND `activities`.`subject_id` = 248646 ORDER BY `stories`.`position` DESC, `activities`.`enacted_at` DESC, `activities`.`id` DESC LIMIT 1"}