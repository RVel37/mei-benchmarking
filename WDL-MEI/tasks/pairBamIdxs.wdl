wdl 1.0

task pairBamIdxs {
    input {
    File bam
    Array[File] bais 
    }

    command <<<

        bam_basename=$(basename ~{bam})
        bai_file="~{bam}.bai"

        # look for a matching BAI in the provided array
        matching_bai=""
        for bai in ~{sep=' ' bais}; do
            bai_base=$(basename "$bai" .bai)
            if [[ "$bai_base" == "$bam_basename" || "$bai_base" == "$bam_basename.bam" ]]; then
                matching_bai=$bai
                break
            fi
        done

        # index bam if necessary
        if [[ -n "$existing_bai" ]]; then
            # copy so it goes in same directory as bam
            cp "$existing_bai" "${bam_basename}.bam.bai" 
        else
            samtools index ~{bam}
        fi
    >>>

    output {
        File bam = "~{bam}"
        File bai = "~{basename(bam)}.bam.bai"
    }

    runtime {
        docker: "swglh/samtools:v1.18"
    }
}