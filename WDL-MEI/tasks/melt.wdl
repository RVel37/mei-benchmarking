version 1.0

task melt {
  input {
    File bam
    File bai
    File refGenomeBwaTar
    String dockerMelt
  }

  # dynamic instance
  Int disk_gb = ceil( 2* (size(bam, "GiB") + size(refGenomeBwaTar, "GiB")) ) + 2
  String mem = "32 GB"
  Int threads = 16
  Int cpu = (threads)/2

  command <<<

    # unpack reference genome
    mkdir -p ref
    tar -zxvf ~{refGenomeBwaTar} -C ref # --no-same-owner
    referenceFasta=$(ls ref/*.fasta | head -n1)

    # make mei reference list
    mkdir -p reference
cat > reference/mei_list.txt <<EOF
/MELT/MELTv2.0.5_patch/me_refs/Hg38/ALU_MELT.zip
/MELT/MELTv2.0.5_patch/me_refs/Hg38/LINE1_MELT.zip
/MELT/MELTv2.0.5_patch/me_refs/Hg38/SVA_MELT.zip
EOF

    # concat if MELT produced any VCFs
    if compgen -G "./Comparisons/*.final_comp.vcf" > /dev/null; then
      bcftools concat -a ./Comparisons/*.final_comp.vcf \
        -o "~{basename(bam, ".bam")}.melt.vcf"
    fi

    mv "melt.log" "~{basename(bam, ".bam")}.melt.log"
  >>>

  output {
    File? vcf = "~{basename(bam, ".bam")}.melt.vcf"
    File log  = "~{basename(bam, ".bam")}.melt.log"
  }

  runtime {
        docker: "${dockerMelt}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}
