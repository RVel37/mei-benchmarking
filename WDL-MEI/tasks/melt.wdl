version 1.0

task melt {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerMelt
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) )
  String mem = "32 GB"
  Int threads = 16
  Int cpu = (threads)/2

  command <<<

    # unpack reference genome
    mkdir -p ref
    tar -zxvf ~{refGenomeBwaTar} -C ref --no-same-owner
    referenceFasta=$(ls ref/*.fasta | head -n1)

    mkdir -p melt_ref

# make mei reference list 
cat > melt_ref/mei_list.txt <<EOF
/MELT/MELTv2.0.5_patch/me_refs/Hg38/ALU_MELT.zip
/MELT/MELTv2.0.5_patch/me_refs/Hg38/LINE1_MELT.zip
/MELT/MELTv2.0.5_patch/me_refs/Hg38/SVA_MELT.zip
EOF

    cat melt_ref/mei_list.txt

    java -jar /MELT/MELTv2.0.5_patch/MELT.jar Single \
      -bamfile ~{bam} \
      -h "$referenceFasta" \
      -t melt_ref/mei_list.txt \
      -w $(pwd) \
      -n /MELT/MELTv2.0.5_patch/add_bed_files/Hg38/Hg38.genes.bed \
      -c 8 

      # rename outputs
      mv ALU.final_comp.vcf ~{basename(bam, '.bam')}.ALU.final_comp.vcf
      mv LINE1.final_comp.vcf ~{basename(bam, '.bam')}.LINE1.final_comp.vcf
      mv SVA.final_comp.vcf ~{basename(bam, '.bam')}.SVA.final_comp.vcf

  >>>

  output {
    File alu_vcf = "~{basename(bam, '.bam')}.ALU.final_comp.vcf"
    File line1_vcf = "~{basename(bam, '.bam')}.LINE1.final_comp.vcf"
    File sva_vcf = "~{basename(bam, '.bam')}.SVA.final_comp.vcf"
  }

  runtime {
        docker: "${dockerMelt}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}