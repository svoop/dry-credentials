require_relative '../../../spec_helper'

describe Dry::Credentials do
  it "must be defined" do
    _(Dry::Credentials::VERSION).wont_be_nil
  end
end
