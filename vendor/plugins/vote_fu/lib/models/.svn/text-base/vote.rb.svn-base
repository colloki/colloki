class Vote < ActiveRecord::Base

  named_scope :for_voter,    lambda { |*args| {:conditions => ["voter_id = ? AND voter_type = ?", args.first.id, args.first.type.name]} }
  # named_scope :for_voter_pos,    lambda { |*args| {:conditions => {:voter_id => args.first.id, :voter_type => args.first.class.name, :vote => 't'}}}
  # named_scope :for_voter_neg,    lambda { |*args| {:conditions => {:voter_id => args.first.id, :voter_type => args.first.class.name, :vote => 'f'}}}
  # named_scope :for_voter_pos,    lambda { |*args| {:conditions => ["voter_id = ? AND voter_type = ? AND (vote = 't' OR vote = 1)", args.first.id, args.first.class.name]} }
  # named_scope :for_voter_neg,    lambda { |*args| {:conditions => ["voter_id = ? AND voter_type = ? AND (vote = 'f' OR vote = 0)", args.first.id, args.first.class.name]} }
  named_scope :for_voter_pos,    lambda { |*args| {:conditions => { :voter_id =>args.first.id, :voter_type => args.first.class.name, :vote => true}}}
  named_scope :for_voter_neg,    lambda { |*args| {:conditions => { :voter_id =>args.first.id, :voter_type => args.first.class.name, :vote => false}}}  

  named_scope :for_voteable, lambda { |*args| {:conditions => ["voteable_id = ? AND voteable_type = ?", args.first.id, args.first.class.name]} }
  named_scope :recent,       lambda { |*args| {:conditions => ["created_at > ?", (args.first || 2.weeks.ago).to_s(:db)]} }
  named_scope :descending, :order => "created_at DESC"

  # NOTE: Votes belong to the "voteable" interface, and also to voters
  belongs_to :voteable, :polymorphic => true
  belongs_to :voter,    :polymorphic => true
  
  attr_accessible :vote

  # Uncomment this to limit users to a single vote on each item. 
  #validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id]
  
end