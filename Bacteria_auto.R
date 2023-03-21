# Get a list of all files in the current directory
file_list <- list.files()

# Loop through the file list and extract the contents of each gzip file
for (file in file_list) {
  if (endsWith(file, ".gz")) {  # Check if the file is a gzip file
    # Open the compressed file and create a new text file
    gz_file <- gzfile(file, "rb")
    new_file <- sub(".gz$", "", file)  # Remove the ".gz" extension
    
    if (endsWith(file, "fna.gz")) {  # Check if the file is a .fna.gz file
      new_file <- sub(".fna", ".fa", new_file)  # Change the extension to .fa
    } else if (endsWith(file, "gff.gz")) {  # Check if the file is a .gff.gz file
      new_file <- sub(".gff.gz", ".gff", new_file)  # Change the extension to .gff
    }
    
    txt_file <- file(new_file, "wb")  # Create the new text file
    
    # Read the contents of the compressed file and write to the new text file
    while (length(buf <- readBin(gz_file, "raw", n = 2^16)) > 0) {
      writeBin(buf, txt_file)
    }
    
    # Close the files
    close(txt_file)
    close(gz_file)
  }
}

############ 여기까지는 집파일 풀고 fa 로 수정





####################### bowtie part

# Get a list of all the .fa files in the current directory
fa_files <- list.files(pattern = ".fa$")

# Loop through the list of .fa files and run bowtie2-build on each file
for (fa_file in fa_files) {
  # Get the file name without the .fa extension
  index_name <- sub(".fa$", "", fa_file)
  
  # Run bowtie2-build on the file
  system(paste("bowtie2-build", fa_file, index_name))
}




source("~/R/Source/Beta/NCBIDB_gff3.R")

gff_files<-list.files(pattern = ".gff$")
DBAnnotation(gff_files)
DBAnnotation2("gene.xlsx","CDS.xlsx")


# make an empty excel


# Create an empty workbook
wb <- createWorkbook()

# Add a worksheet to the workbook
addWorksheet(wb, "Sheet1")

# Save the workbook as an Excel file
saveWorkbook(wb, "modified.gene.anno.xlsx")



# library(openxlsx)

# Read in the "gene.anno.xlsx" file
gene_anno <- read.xlsx("gene.anno.xlsx")

# Extract the "Name" or "gene" column
gene_names <- gene_anno$Name  # Or gene_anno$gene

# Create a data frame with the gene names
gene_df <- data.frame(Name = gene_names)

# Write the data frame to a new Excel file
write.xlsx(gene_df, "modified.gene.anno.xlsx", rowNames = FALSE)

modified_gene_anno<-read.xlsx("modified.gene.anno.xlsx")
Name<-gene_anno$Name
seqnames<-gene_anno$seqnames
start<-gene_anno$start
end<-gene_anno$end
width<-gene_anno$width
strand<-gene_anno$strand
Entrez_ID<-gene_anno$Dbxref
protein_id<-gene_anno$protein_id
type<-gene_anno$type
gene_biotype<-gene_anno$gene_biotype
product<-gene_anno$product
NCBI_search<-gene_anno$Name

additional_columns<-data.frame(Name,seqnames,start,end,width,strand,Entrez_ID,protein_id,type,gene_biotype,product,NCBI_search)

merged_gene_anno <- merge(modified_gene_anno, additional_columns, by = "Name")

write.xlsx(merged_gene_anno, "modified.gene.anno.xlsx", rowNames = FALSE)





library(stringr)
library(readxl)
library(dplyr)

df <- read_excel("modified.gene.anno.xlsx")
df$Entrez_ID <- str_extract(df$Entrez_ID, "(?<=:)[^:]*$")
df <- df %>%
  rename(`Gene symbol` = Name, `Entrez ID` = Entrez_ID)
write.xlsx(df, "modified.gene.anno.xlsx", rowNames = FALSE)



