$:.unshift(File.dirname(__FILE__))
require "spec_helper"

job_json = <<-JSON
  {
    "url": "/some/job/url",
    "finished_build": {
      "id": 928,
      "name": "finished",
      "status": "%s",
      "job_name": "atc",
      "url": "/finished-build"
    },
    "next_build": {
      "id": 929,
      "name": "next",
      "status": "%s",
      "job_name": "atc",
      "url": "/next-build"
    }
  }
JSON

describe_check :Concourse, "concourse" do
  before(:all) { WebMock.disable_net_connect! }
  after(:all) { WebMock.allow_net_connect! }

  before(:each) do
    [
      ["succeeded", "pending"],
      ["succeeded", "started"],
      ["failed", "pending"],
      ["failed", "started"],
      ["errored", "pending"],
      ["errored", "started"],
      ["aborted", "pending"],
      ["aborted", "started"],
    ].each do |finished_status, next_status|
      WebMock.stub_request(:get, "http://server.example.com/api/v1/teams/some-team/pipelines/some-pipeline/jobs/#{finished_status}-#{next_status}").
        to_return(:status => 200, :body => job_json % [finished_status, next_status], :headers => {})

      WebMock.stub_request(:get, "http://username77:passw0rd@server.example.com/api/v1/teams/some-team/pipelines/some-pipeline/jobs/#{finished_status}-#{next_status}").
        to_return(:status => 200, :body => job_json % [finished_status, next_status], :headers => {})
    end
  end

  context "with no auth" do
    it_returns_ok   %w(http://server.example.com some-team some-pipeline succeeded-pending)
    it_returns_ok   %w(http://server.example.com some-team some-pipeline succeeded-started)

    it_returns_fail %w(http://server.example.com some-team some-pipeline failed-pending)
    it_returns_fail %w(http://server.example.com some-team some-pipeline errored-pending)
    it_returns_fail %w(http://server.example.com some-team some-pipeline aborted-pending)
    it_returns_fail %w(http://server.example.com some-team some-pipeline failed-started)
    it_returns_fail %w(http://server.example.com some-team some-pipeline errored-started)
    it_returns_fail %w(http://server.example.com some-team some-pipeline aborted-started)

    it_returns_changing %w(http://server.example.com some-team some-pipeline succeeded-pending)
    it_returns_changing %w(http://server.example.com some-team some-pipeline failed-pending)
    it_returns_changing %w(http://server.example.com some-team some-pipeline errored-pending)
    it_returns_changing %w(http://server.example.com some-team some-pipeline succeeded-started)
    it_returns_changing %w(http://server.example.com some-team some-pipeline failed-started)
    it_returns_changing %w(http://server.example.com some-team some-pipeline errored-started)

    let(:opts) { %w(http://server.example.com some-team some-pipeline succeeded-started) }

    it "returns a useful url" do
      url = subject.latest_status.as_json[:url]
      expect(url).to eq("http://server.example.com/teams/some-team/pipelines/some-pipeline/jobs/some-job/builds/2")
    end
  end

  context 'when using basic auth' do
    it_returns_ok   %w(http://server.example.com username77 passw0rd some-team some-pipeline succeeded-pending)
    it_returns_ok   %w(http://server.example.com username77 passw0rd some-team some-pipeline succeeded-started)

    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline failed-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline errored-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline aborted-pending)
    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline failed-started)
    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline errored-started)
    it_returns_fail %w(http://server.example.com username77 passw0rd some-team some-pipeline aborted-started)

    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline succeeded-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline failed-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline errored-pending)
    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline succeeded-started)
    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline failed-started)
    it_returns_changing %w(http://server.example.com username77 passw0rd some-team some-pipeline errored-started)
  end
end
