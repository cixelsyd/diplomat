# Copyright 2014, Steven Craig
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'base64'
require 'faraday'

module Diplomat
  class Agent < Diplomat::RestClient

    attr_reader :checks, :services, :members, :self

    def checks
      ret = @conn.get "/v1/agent/checks"
      return JSON.parse(ret.body)
    end

    def services
      ret = @conn.get "/v1/agent/services"
      return JSON.parse(ret.body)
    end

    def members
      ret = @conn.get "/v1/agent/members"
      return JSON.parse(ret.body)
    end

    def self
      ret = @conn.get "/v1/agent/self"
      return JSON.parse(ret.body)
    end

    # Register a service
    # @param service_id [String] the unique id of the service
    # @param name [String] the name
    # @param tags [Array] Arbitrary array of string
    # @param port [Integer] Integer service endpoint portnumber
    # @param check [Hash] only one of (Script and Interval) or TTL
      # script [String] command to be run for check
      # interval [String] frequency (with units) of the check execution
      # ttl [String] time (with units) to mark a check down
    # @return [Integer] Status code
    def register_service service_id, name, tags, port, check
      json = JSON.generate(
      {
        "ID" => service_id,
        "Name" => name,
        "Tags" => tags,
        "Port" => port,
        "Check" => check
      }
      )

      ret = @conn.put do |req|
        req.url "/v1/agent/service/register"
        req.body = json
      end
      
      return true if ret.status == 200
    end

    # Deregister a service
    # @param service_id [String] the unique id of the service
    # @return [Integer] Status code
    def deregister_service service_id
      ret = @conn.get "/v1/agent/service/deregister/#{service_id}"
      return true if ret.status == 200
    end

    # @note This is sugar, see (#checks)
    def self.checks
      Diplomat::Agent.new.checks
    end

    # @note This is sugar, see (#services)
    def self.services
      Diplomat::Agent.new.services
    end

    # @note This is sugar, see (#members)
    def self.members
      Diplomat::Agent.new.members
    end

    # @note This is sugar, see (#self)
    def self.self
      Diplomat::Agent.new.self
    end

    # @note This is sugar, see (#register_service)
    def self.register_service *args
      Diplomat::Agent.new.register_service *args
    end

    # @note This is sugar, see (#deregister_service)
    def self.deregister_service *args
      Diplomat::Agent.new.deregister_service *args
    end

  end
end
