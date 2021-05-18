$:.unshift(File.dirname(__FILE__))
require "spec_helper"

codeship_successful_builds_json = <<~JSON
builds:[{
  "project_uuid":"project-uuid",
  "commit_message":"a commit message",
  "status":"success",
  "ref":"heads/main",
  "uuid":"build-uuid",
  "queued_at":"1970-01-01T00:00:00Z",
  "username":"flynn",
  "commit_sha":"000000000",
  "finished_at":"1970-01-01T01:00:00Z",
  "allocated_at":null,
  "organization_uuid":"org-uuid",
  "links: {
    "pipelines":"https://api.codeship.com/v2/organizations/org-uuid/projects/project-uuid/builds/build-uuid/pipelines"
  }
},{
  "project_uuid":"project-uuid",
  "commit_message":"a poor commit message",
  "status":"failed",
  "ref":"heads/branch-fail",
  "uuid":"build-uuid-failed",
  "queued_at":"1970-01-01T00:00:00Z",
  "username":"flynn",
  "commit_sha":"000000001",
  "finished_at":"1970-01-01T01:00:00Z",
  "allocated_at":null,
  "organization_uuid":"org-uuid",
  "links: {
    "pipelines":"https://api.codeship.com/v2/organizations/org-uuid/projects/project-uuid/builds/build-uuid-failed/pipelines"
  }
}]
JSON

describe_check :Codeship, "codeship" do
  before { WebMock.disable_net_connect! }
  after { WebMock.allow_net_connect! }

  before(:each) do
    WebMock.stub_request(:get, "https://api.codeship.com/v2/auth").
      to_return(:status => 200, :body => '{"access_token":"access-token"}', :headers => {})
    WebMock.stub_request(:get, "https://api.codeship.com/v2/organizations/org-uuid/projects/project-uuid/builds").
      to_return(:status => 200, :body => codeship_builds_json, :headers => {})
  end

  it_returns_ok   %w(org-uuid project-uuid flynn password main)
  it_returns_fail %w(org-uuid project-uuid flynn password branch-fail)
end
