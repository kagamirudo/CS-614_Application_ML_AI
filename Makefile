.PHONY: push help

# Default commit message if not provided
MESSAGE ?= "Update repository"

help:
	@echo "Available targets:"
	@echo "  make push              - Commit and push changes (uses default message)"
	@echo "  make push MESSAGE=\"msg\" - Commit and push with custom message"
	@echo "  make help              - Show this help message"

push:
	@echo "Staging all changes..."
	@git add -A
	@echo "Committing with message: $(MESSAGE)"
	@git commit -m $(MESSAGE) || echo "No changes to commit"
	@echo "Pushing to GitHub..."
	@git push origin main || (echo "Error: Could not push. Make sure you have:"; \
		echo "  1. Created the repository on GitHub"; \
		echo "  2. Set up the remote: git remote add origin <your-repo-url>"; \
		exit 1)
	@echo "Successfully pushed to GitHub!"
