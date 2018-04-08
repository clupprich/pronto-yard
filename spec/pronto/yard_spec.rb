require 'spec_helper'

describe Pronto::Yard do
  describe '#run' do
    def run_in_sample(cmd)
      Dir.chdir('./spec/sample') do
        system cmd, out: File::NULL, err: File::NULL
      end
    end

    def init_sample
      run_in_sample <<-SH
        git init .
        mkdir lib
        SH
    end

    def cleanup_sample
      run_in_sample <<-SH
        rm -rf .git
        rm -rf lib
        SH
    end

    def create_example_file_in_master
      run_in_sample <<-SH
        echo "class Example
        def run(account, secret)
        end
        end" > lib/example.rb
        git add .
        git commit -am "Initial commit"
        SH
    end

    def add_example_docs_in_develop
      run_in_sample <<-SH
        git checkout -b develop
        echo "class Example
        # @param user
        # @param key
        def run(account, secret)
        end
        end" > lib/example.rb
        git add .
        git commit -am "Add docs"
        SH
    end

    subject do
      ::Rugged::Repository.discover('./spec/sample').workdir
      repo = Pronto::Git::Repository.new('./spec/sample')
      patches = repo.diff('master', {})

      Pronto::Yard.new(patches, patches.commit).run
    end

    context 'with no yard issues present' do
      before do
        init_sample
        create_example_file_in_master
      end

      after do
        cleanup_sample
      end

      it 'reports no errors' do
        expect(subject.length).to eq 0
      end
    end

    context 'with yard issues present' do
      before do
        init_sample
        create_example_file_in_master
        add_example_docs_in_develop
      end

      after do
        cleanup_sample
      end

      it 'reports errors' do
        expect(subject.length).to eq 2
      end

      it 'has a message' do
        expect(subject.first.msg).to eq '@param tag has unknown parameter name: user'
      end

      it 'has a path' do
        expect(subject.first.path).to eq 'lib/example.rb'
      end

      it 'reports as info' do
        expect(subject.first.level).to eq :info
      end
    end
  end
end
