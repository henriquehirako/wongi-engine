require 'spec_helper'

describe "ANY rule" do

  include Wongi::Engine::DSL

  before :each do
    @engine = Wongi::Engine.create
  end

  def engine
    @engine
  end

  context "with just one option" do

    it "should act like a positive matcher" do

      engine << rule('one-option') {
        forall {
          any {
            option {
              has 1, 2, :X
              has :X, 4, 5
            }
          }
        }
      }

      production = engine.productions['one-option']

      engine << [1, 2, 3]
      engine << [3, 4, 5]

      expect(production.size).to eq(1)

    end

  end

  context "with several options" do

    specify "all matching branches must pass" do

      engine << rule('two-options') {
        forall {
          has 1, 2, :X
          any {
            option {
              has :X, 4, 5
            }
            option {
              has :X, "four", "five"
            }
          }
        }
        make {
          collect :X, :threes
        }
      }

      production = engine.productions['two-options']

      engine << [1, 2, 3]
      engine << [3, 4, 5]
      engine << [1, 2, "three"]
      engine << ["three", "four", "five"]

      expect(production.size).to eq(2)
      expect( engine.collection(:threes) ).to include(3)
      expect( engine.collection(:threes) ).to include("three")

    end

  end

  context "with two options and same assignments" do
    let :production do
      engine << rule do
        forall {
          any {
            option {
              has :A, :path1, :PathVar
            }
            option {
              has :A, :path2, :PathVar
            }
          }
        }
        make {
          collect :PathVar, :paths
        }
      end
    end

    specify 'should fire on the first path', debug: true do
      engine << [:x, :path1, true]
      expect(production.tokens).to have(1).item
      expect(engine.collection(:paths)).to include(true)
    end

    specify 'should fire on the second path', debug: true do
      engine << [:x, :path2, true]
      expect(production.tokens).to have(1).item
      expect(engine.collection(:paths)).to include(true)
    end
  end

end
