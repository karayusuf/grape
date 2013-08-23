require 'spec_helper'

module Grape
  describe RouteSet do
    let(:endpoint) do
      double("Grape::Endpoint", options: {}, settings: {})
    end

    describe "#initialize" do
      it "remembers the endpoint" do
        route_set = RouteSet.new(endpoint)
        expect(route_set.endpoint).to be(endpoint)
      end

      it "remembers the endpoint's options" do
        route_set = RouteSet.new(endpoint)
        expect(route_set.options).to be(endpoint.options)
      end

      it "remembers the endpoint's settings" do
        route_set = RouteSet.new(endpoint)
        expect(route_set.settings).to be(endpoint.settings)
      end
    end

    describe "#prepare_path" do
      it "delegates to the endpoint" do
        expect(endpoint).to receive(:prepare_path).with('some/path')

        route_set = RouteSet.new(endpoint)
        route_set.prepare_path('some/path')
      end
    end

    describe "#compile_path" do
      it "delegates to the endpoint" do
        expect(endpoint).to receive(:compile_path).with('some/path')

        route_set = RouteSet.new(endpoint)
        route_set.compile_path('some/path')
      end
    end

    describe "#namespace" do
      it "delegates to the endpoint" do
        expect(endpoint).to receive(:namespace)

        route_set = RouteSet.new(endpoint)
        route_set.namespace
      end
    end

    describe "#anchor" do
      it "returns true when the anchor route option is nil" do
        endpoint.stub(:options).and_return(route_options: {})

        route_set = RouteSet.new(endpoint)
        expect(route_set.anchor).to be_true
      end

      it "returns the anchor route option" do
        endpoint.stub(:options).and_return(route_options: { anchor: 'anchor' })
       
        route_set = RouteSet.new(endpoint)
        expect(route_set.anchor).to eql('anchor')
      end
    end

    describe "#methods_and_paths" do
      it "combines elements from the method and path options" do
        endpoint.stub(:options).and_return({
          method: ['GET', 'POST'],
          path: ['/foo', '/bar', '/baz']
        })

        route_set = RouteSet.new(endpoint)
        expect(route_set.methods_and_paths).to eql([
          ['GET', '/foo'],
          ['GET', '/bar'],
          ['GET', '/baz'],
          ['POST', '/foo'],
          ['POST', '/bar'],
          ['POST', '/baz']
        ])
      end
    end

  end
end
