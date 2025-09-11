version 1.0

task mobster {
  input {
    File bam
    File bai
    File refGenomeBwaTar
  }

  command <<<

  >>>

  output {
    File? vcf      = "~{basename(bam, ".bam")}.mobster.vcf"
  }

  runtime {
    docker: 
  }
}