module ErpServices::Txns
	module ActsAsBizTxnAccount
		
		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_biz_txn_account
    								
			  has_one :biz_txn_acct_root, :as => :biz_txn_acct
			  
			  [
			    :biz_txn_acct_type,
			    :biz_txn_events,
			    :biz_txn_acct_party_roles,
			    :txn_events,
			    :txns,
			    :account_type
			  ].each do |m| delegate m, :to => :biz_txn_acct_root end
			  
			  extend ErpServices::Txns::ActsAsBizTxnAccount::SingletonMethods
			  include ErpServices::Txns::ActsAsBizTxnAccount::InstanceMethods												
							     			
		  end

		end
		
		module InstanceMethods
		  def account_root
				biz_txn_acct_root
			end		
	
		  def after_update
      	self.biz_txn_acct_root.description = self.description
      	self.biz_txn_acct_root.save
      end  

      def after_initialize()
        if (self.biz_txn_acct_root.nil?)
          t = BizTxnAcctRoot.new
          t.description = self.description
          self.biz_txn_acct_root = t
          t.biz_txn_acct = self
        end
      end
        
      def after_create
        self.biz_txn_acct_root.save
      end
		
		end
		
		module SingletonMethods
		end
		
	end
end

ActiveRecord::Base.send(:include, ErpServices::Txns::ActsAsBizTxnAccount)