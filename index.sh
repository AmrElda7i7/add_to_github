#!/bin/bash
target_dir="/home/amr-fathy/programming /my_projects/important"
file="/home/amr-fathy/GitHubProject/repos"
errors="/home/amr-fathy/GitHubProject/errors"
success="/home/amr-fathy/GitHubProject/success"
empty="/home/amr-fathy/GitHubProject/empty"

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$errors"
}
log_success() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$success"
}
log_empty() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$empty"
}

dirs=$(find "$target_dir" -mindepth 1 -maxdepth 1 -type d 2>> "$errors" | while IFS= read -r dir; do
  basename "$dir"
done)

dirs_arr=()

while IFS= read -r dir; do
  if grep -q "$dir" "$file"; then
    continue
  else
    dirs_arr+=("$dir")
  fi
done <<< "$dirs" 2>> "$errors"

if [ ${#dirs_arr[@]} -eq 0 ]; then
    log_empty "No directories to add to githyb"
    exit 1
fi

for dir in "${dirs_arr[@]}"; do
    path="/home/amr-fathy/programming /my_projects/important/$dir"
    
    if [ -d "$path" ]; then
        cd "$path" 2>> "$errors" || { log_error "Failed to change directory to '$path'"; exit 1; }
        
        gh repo create "$dir" --private 2>> "$errors" || { log_error "Failed to create GitHub repository '$dir'"; exit 1; }
        git init 2>> "$errors"
        git add * 2>> "$errors"
        git commit -m "first commit" 2>> "$errors"
        git branch -M main 2>> "$errors"
        git remote add origin "git@github.com:AmrElda7i7/$dir.git" 2>> "$errors"
        git push -u origin main 2>> "$errors" || { log_error "Failed to push to repository '$dir'"; exit 1; }
        
        echo "$dir" >> "$file"
    else
        log_error "Directory '$path' does not exist."
    fi
done

log_success "All directories have been processed successfully."
