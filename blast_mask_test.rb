require "test/unit"
require 'blast_mask'
require 'tempfile'

class BlastMaskTest < Test::Unit::TestCase
  def test_mask_sequence1
    b = BlastHitArray.new
    assert_equal 'ABC', b.masked_sequence('ABC')
    b.push Hit.new(2,2)
    assert_equal 'AXC', b.masked_sequence('ABC')
    b.push Hit.new(1,3)
    assert_equal 'XXX', b.masked_sequence('ABC')
  end
  
  def test_command_line
    input_blast = <<EOF
Aqu1.200001	Aqu1.200001	100.00	294	0	0	1	5	1	294	2e-166	583
Aqu1.200001	Aqu1.200002	100.00	74	0	0	7	8	237	164	5e-35	147
Aqu1.200002	Aqu1.200002	98.00	74	0	223	5	7	237	164	5e-35	147
EOF
    input_fasta=<<EOF
>Aqu1.200001
ATGCATGC
>Aqu1.200002
ATGCATGCAA
>Aqu1.200003
ATGCA
EOF
    expected=<<EOF
>Aqu1.200001
XXXXXTXX
>Aqu1.200002
ATGCXXXCAA
>Aqu1.200003
ATGCA
EOF
    
    Tempfile.open('input_blast') do |tempfile_blast|
      tempfile_blast.puts input_blast
      tempfile_blast.close
      
      Tempfile.open('input_blast') do |tempfile_fasta|
        tempfile_fasta.puts input_fasta
        tempfile_fasta.close
        
        Tempfile.open('expected') do |tempfile_expected|
          `blast_mask.rb #{tempfile_fasta.path} #{tempfile_blast.path} >#{tempfile_expected.path}`
          assert_equal expected, File.open(tempfile_expected.path,'r').read
        end
      end
    end
  end
end