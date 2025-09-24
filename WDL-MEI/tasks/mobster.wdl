version 1.0

task mobster {
    input {
        File bam
        File bai
        String dockerMobster
    }

    # dynamic instance
    Int disk_gb = ceil( 2* (size(bam, "GiB"))) + 2
    String mem = "32 GB"
    Int threads = 8
    Int cpu = (threads)/2

    command <<<

        # Mobster only ran correctly if inputs are in /mobster subdir
        # in interactive session. reference copied variables below if
        # it doesn't work normally.

        cd /mobster
        mkdir -p data; cp ~{bam} ~{bai} .
        
        # change 'Mobster.properties' reference file from hg19 to 38
        sed -i 's|repmask/hg19_alul1svaerv.rpmsk|repmask/alu_l1_herv_sva_other_grch38_accession_ucsc.rpmsk|' /mobster/lib/Mobster.properties

        #  DEBUG: show Mobster properties that determine if fasta required
        grep -E "REPEATMASK_FILE|MAPPING_TOOL|MOBIOME_MAPPING_CMD|REPMASK" /mobster/lib/Mobster.properties || true

        # confirm the repeatmask file exists
        grep -E "REPEATMASK_FILE" /mobster/lib/Mobster.properties -A1

        java -Xmx8G \
            -cp /mobster/target/MobileInsertions-0.2.4.1.jar \
            org.umcn.me.pairedend.Mobster \
            -properties /mobster/lib/Mobster.properties \
            -in ~{bam} \
            -sn ~{basename(bam, ".bam")} \
            -out "data/~{basename(bam, '.bam')}"

        # move text output        
        if compgen -G "data/~{basename(bam, '.bam')}*.txt" > /dev/null; then
            mv data/~{basename(bam, '.bam')}*.txt ~{basename(bam, '.bam')}.mobster.txt
        fi
    >>>

    output {
        File? txt = "~{basename(bam, ".bam")}.mobster.txt"
    }

    runtime {
        docker: "${dockerMobster}"
        cpu: cpu
        gpu: false
        memory: "${mem}"
        disks: "local-disk ${disk_gb} SSD"
    }
}



task mobVcf {
    input {
        File? txt
        String dockerMobVcf
    }

    command <<<
    java -jar /mobstertovcf/MobsterVCF-0.0.1-SNAPSHOT.jar \
    -file ~{txt} \
    -out ~{basename(txt, ".txt")}.mobster.vcf
    >>>

    output {
        File? vcf = "~{basename(txt, ".txt")}.mobster.vcf"
    }
}