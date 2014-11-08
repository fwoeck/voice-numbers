require 'spec_helper'
require 'dataset'
require 'call'

describe Dataset do

  let(:calls) { YAML.load_file './spec/fixtures/successful-calls.yml' }
  let(:t0)    { Time.at(1415441020) }
  let(:ds)    { Dataset.new(calls)  }


  it 'creates a basic hash structure for empty call sets' do
    ds = Dataset.new([])
    allow(ds).to receive(:langs)  { {'en' => '', 'fr' => ''} }
    allow(ds).to receive(:skills) { {'s1' => '', 's2' => ''} }

    expect(ds.to_hash).to eq(
      {
        'max_delay' => {
          'en' => {'s1' => 0, 's2' => 0},
          'fr' => {'s1' => 0, 's2' => 0}
        },
        'queued_calls' => {
          'en' => {'s1' => 0, 's2' => 0},
          'fr' => {'s1' => 0, 's2' => 0}
        },
        'average_delay' => {
          'en' => {'s1' => 0, 's2' => 0},
          'fr' => {'s1' => 0, 's2' => 0}
        },
        'dispatched_calls' => {
          'en' => {'s1' => 0, 's2' => 0},
          'fr' => {'s1' => 0, 's2' => 0}
        },
        'active_call_count'      => 0,
        'queued_call_count'      => 0,
        'pre_queued_call_count'  => 0,
        'dispatched_call_count'  => 0,
        'queued_calls_delay_max' => 0,
        'queued_calls_delay_avg' => 0
      }
    )
  end


  context 'aggregate statistics for a set of calls' do

    before do
      allow(ds).to receive(:langs)  {
        {'de' => '', 'en' => '', 'es' => '', 'fr' => '', 'it' => ''}
      }

      allow(ds).to receive(:skills) {
        {'new_booking' => '', 'ext_booking' => '', 'payment' => '', 'other' => ''}
      }
    end


    it 'calculates the max_delay_hash' do
      Timecop.freeze(t0) do
        expect(ds.max_delay_hash).to eq({
          'de' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'en' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'es' => {'new_booking' => 4, 'ext_booking' => 0, 'payment' => 0, 'other' => 2},
          'fr' => {'new_booking' => 0, 'ext_booking' => 1, 'payment' => 0, 'other' => 0},
          'it' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0}
        })
      end
    end


    it 'calculates the queued_calls_hash' do
      Timecop.freeze(t0) do
        expect(ds.queued_calls_hash).to eq({
          'de' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'en' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'es' => {'new_booking' => 1, 'ext_booking' => 0, 'payment' => 0, 'other' => 1},
          'fr' => {'new_booking' => 0, 'ext_booking' => 1, 'payment' => 0, 'other' => 0},
          'it' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0}
        })
      end
    end


    it 'calculates the average_delay_hash' do
      Timecop.freeze(t0) do
        expect(ds.average_delay_hash).to eq({
          'de' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'en' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'es' => {'new_booking' => 1, 'ext_booking' => 0, 'payment' => 0, 'other' => 1},
          'fr' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0},
          'it' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 0, 'other' => 0}
        })
      end
    end


    it 'calculates the dispatched_calls_hash' do
      Timecop.freeze(t0) do
        expect(ds.dispatched_calls_hash).to eq({
          'de' => {'new_booking' => 1, 'ext_booking' => 0, 'payment' => 1, 'other' => 0},
          'en' => {'new_booking' => 0, 'ext_booking' => 0, 'payment' => 1, 'other' => 1},
          'es' => {'new_booking' => 1, 'ext_booking' => 1, 'payment' => 0, 'other' => 0},
          'fr' => {'new_booking' => 0, 'ext_booking' => 1, 'payment' => 1, 'other' => 1},
          'it' => {'new_booking' => 2, 'ext_booking' => 0, 'payment' => 1, 'other' => 0}
        })
      end
    end


    it 'calculates the active_call_count' do
      expect(ds.active_call_count).to eq(27)
    end


    it 'calculates the queued_call_count' do
      expect(ds.queued_call_count).to eq(3)
    end


    it 'calculates the pre_queued_call_count' do
      expect(ds.pre_queued_call_count).to eq(12)
    end


    it 'calculates the dispatched_call_count' do
      expect(ds.dispatched_call_count).to eq(12)
    end


    it 'calculates the queued_calls_delay_max' do
      Timecop.freeze(t0) do
        expect(ds.queued_calls_delay_max).to eq(4)
      end
    end


    it 'calculates the queued_calls_delay_avg' do
      Timecop.freeze(t0) do
        expect(ds.queued_calls_delay_avg).to eq(2)
      end
    end
  end
end
