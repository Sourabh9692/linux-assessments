# Linux Practice Labs

A clean, beginner-friendly repository to track my Linux assessments, shell scripts, and other related mini-projects.

> **Owner:** @Sourabh9692  
> **Created:** 2025-09-22

---

## 📁 Repository Structure

```
linux-assessments-starter/
├── README.md
├── .gitignore
├── LICENSE
└── assessments/
    └── exercise-01-creating-local-users/
        ├── add-local-user.sh         # reference implementation
        ├── Exercise-01-Solution-Final.pdf
        └── Exercise-01-Question.pdf  # original prompt (for reference)
```

---

## 🧪 Exercise 01 — Creating Local Users

- **Goal:** Write a script that adds a local user, sets an initial password, forces a password change at first login, and prints username/password/host.
- **Files:**
  - `add-local-user.sh` — reference implementation
  - `Exercise-01-Solution-Final.pdf` — detailed write-up with steps and sample outputs
  - `Exercise-01-Question.pdf` — prompt

### ▶️ How to Run

```bash
# from the exercise folder
cd assessments/exercise-01-creating-local-users

# make executable (first time only)
chmod 755 add-local-user.sh

# run with sudo
sudo ./add-local-user.sh
```

You will be prompted for:
- **username**
- **real name / description**
- **password** (hidden while typing)

The script will:
1) Create the user with a home directory.  
2) Set the password.  
3) Force password change at first login.  
4) Print username, password, and host for help desk copy-paste.

---

## ✅ Git Basics (quick)
```bash
git status
git add .
git commit -m "Meaningful message"
git push
```

## 🧭 Branch Workflow
- `main` — stable, reviewed content
- Feature branches per exercise: `feat/ex01`, `feat/ex02`, etc.

```bash
git checkout -b feat/ex01
# make changes...
git add . && git commit -m "Add Exercise 01 files"
git push -u origin feat/ex01
# open a Pull Request on GitHub → merge to main
```

---

## 📜 License
MIT © 2025 Sourabh Ghosh
