#!/bin/bash

# Function to convert Vietnamese diacritics to non-diacritics
convert_vietnamese() {
    local text="$1"
    # Convert Vietnamese characters
    text="${text//à/a}" && text="${text//á/a}" && text="${text//ạ/a}" && text="${text//ả/a}" && text="${text//ã/a}"
    text="${text//â/a}" && text="${text//ầ/a}" && text="${text//ấ/a}" && text="${text//ậ/a}" && text="${text//ẩ/a}" && text="${text//ẫ/a}"
    text="${text//ă/a}" && text="${text//ằ/a}" && text="${text//ắ/a}" && text="${text//ặ/a}" && text="${text//ẳ/a}" && text="${text//ẵ/a}"
    text="${text//è/e}" && text="${text//é/e}" && text="${text//ẹ/e}" && text="${text//ẻ/e}" && text="${text//ẽ/e}"
    text="${text//ê/e}" && text="${text//ề/e}" && text="${text//ế/e}" && text="${text//ệ/e}" && text="${text//ể/e}" && text="${text//ễ/e}"
    text="${text//ì/i}" && text="${text//í/i}" && text="${text//ị/i}" && text="${text//ỉ/i}" && text="${text//ĩ/i}"
    text="${text//ò/o}" && text="${text//ó/o}" && text="${text//ọ/o}" && text="${text//ỏ/o}" && text="${text//õ/o}"
    text="${text//ô/o}" && text="${text//ồ/o}" && text="${text//ố/o}" && text="${text//ộ/o}" && text="${text//ổ/o}" && text="${text//ỗ/o}"
    text="${text//ơ/o}" && text="${text//ờ/o}" && text="${text//ớ/o}" && text="${text//ợ/o}" && text="${text//ở/o}" && text="${text//ỡ/o}"
    text="${text//ù/u}" && text="${text//ú/u}" && text="${text//ụ/u}" && text="${text//ủ/u}" && text="${text//ũ/u}"
    text="${text//ư/u}" && text="${text//ừ/u}" && text="${text//ứ/u}" && text="${text//ự/u}" && text="${text//ử/u}" && text="${text//ữ/u}"
    text="${text//ỳ/y}" && text="${text//ý/y}" && text="${text//ỵ/y}" && text="${text//ỷ/y}" && text="${text//ỹ/y}"
    text="${text//đ/d}"
    
    # Uppercase versions
    text="${text//À/A}" && text="${text//Á/A}" && text="${text//Ạ/A}" && text="${text//Ả/A}" && text="${text//Ã/A}"
    text="${text//Â/A}" && text="${text//Ầ/A}" && text="${text//Ấ/A}" && text="${text//Ậ/A}" && text="${text//Ẩ/A}" && text="${text//Ẫ/A}"
    text="${text//Ă/A}" && text="${text//Ằ/A}" && text="${text//Ắ/A}" && text="${text//Ặ/A}" && text="${text//Ẳ/A}" && text="${text//Ẵ/A}"
    text="${text//È/E}" && text="${text//É/E}" && text="${text//Ẹ/E}" && text="${text//Ẻ/E}" && text="${text//Ẽ/E}"
    text="${text//Ê/E}" && text="${text//Ề/E}" && text="${text//Ế/E}" && text="${text//Ệ/E}" && text="${text//Ể/E}" && text="${text//Ễ/E}"
    text="${text//Ì/I}" && text="${text//Í/I}" && text="${text//Ị/I}" && text="${text//Ỉ/I}" && text="${text//Ĩ/I}"
    text="${text//Ò/O}" && text="${text//Ó/O}" && text="${text//Ọ/O}" && text="${text//Ỏ/O}" && text="${text//Õ/O}"
    text="${text//Ô/O}" && text="${text//Ồ/O}" && text="${text//Ố/O}" && text="${text//Ộ/O}" && text="${text//Ổ/O}" && text="${text//Ỗ/O}"
    text="${text//Ơ/O}" && text="${text//Ờ/O}" && text="${text//Ớ/O}" && text="${text//Ợ/O}" && text="${text//Ở/O}" && text="${text//Ỡ/O}"
    text="${text//Ù/U}" && text="${text//Ú/U}" && text="${text//Ụ/U}" && text="${text//Ủ/U}" && text="${text//Ũ/U}"
    text="${text//Ư/U}" && text="${text//Ừ/U}" && text="${text//Ứ/U}" && text="${text//Ự/U}" && text="${text//Ử/U}" && text="${text//Ữ/U}"
    text="${text//Ỳ/Y}" && text="${text//Ý/Y}" && text="${text//Ỵ/Y}" && text="${text//Ỷ/Y}" && text="${text//Ỹ/Y}"
    text="${text//Đ/D}"
    
    echo "$text"
}

# Test function
convert_vietnamese "Triển khai ứng dụng thành công"
