class ProposalController < ApplicationController
  def index
    @proposals = Proposal.all
  end
end
