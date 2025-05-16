# BudgetBirdie

*Take Flight With Your Finances*

---

## Table of Contents

1. [Persona & Problem](#persona--problem)
2. [Solution Overview](#solution-overview)
3. [Features](#features)
4. [Technology & Frameworks](#technology--frameworks)
5. [Architecture & Code Organization](#architecture--code-organization)
6. [GitHub Workflow](#github-workflow)
7. [Iterative Development Plan](#iterative-development-plan)
8. [Build & Run Instructions](#build--run-instructions)



## Persona & Problem

**Persona:** Alice, a 25‑year‑old graduate student juggling rent, subscriptions, and everyday expenses.
**Problem:** Tracking spending across spreadsheets and banking apps makes it hard to see trends or recall past purchases.

## Solution Overview

**BudgetBirdie** 
- An Expense tracking app that allows Alice to easily record, view, and delete expenses all in one place, thereby ensuring she has a clear log of all her spending. 



## Features

* **Add Expense**: Form with validation (amount > 0, date ≤ today).
* **View Expenses**: List sorted by date (newest first).
* **Delete Expense**: Swipe‑to‑delete functionality.
* **Expense Summary**: Breakdown of all expenses into visual charts on the basis of amount of money spent.
 

> *Planned for v1.1+:* Swift Charts visualisations, UserNotifications for reminders, ShareSheet export.
> *Planned for v1.2+:* Goals tab and progress bars exporting. 



## Technology & Frameworks

* **SwiftUI**: Declarative UI, navigation, lists, and forms.
* **Core Data**: Local persistence for expense records.



## Architecture & Code Organization

* MVVM‑inspired separation: Views consume Core Data context via environment.
* Persistence logic is isolated in **Services/Persistence.swift**.
* UI components in **Views/**.

```
BudgetBirdie/
├─ Views/
│  ├─ ExpenseListView.swift
│  └─ AddExpenseView.swift
├─ Services/
│  └─ Persistence.swift
└─ BudgetBirdieApp.swift
```


## GitHub Workflow


> Review history & issues: [https://github.com/Erfanur1/BudgetBirdie](https://github.com/Erfanur1/BudgetBirdie)



## Iterative Development Plan

|Iteration  | Goal                    

| **I₀**    | Repo setup & wireframes 
| **I₁**    | Expense CRUD            
| **I₂**    | UI polish & validation  
| **I₃**    | Charts integration      
| **I₄**    | Reminders & export      

---

## Build & Run Instructions

1. **Clone**

   ```bash
   git clone https://github.com/Erfanur1/BudgetBirdie.git
   ```
2. **Open**

   * Double‑click **BudgetBirdie.xcodeproj** in Xcode 15+
3. **Run**

   * Select an iOS 16+ simulator, press **⌘R**
4. **Test**

   * Tap “+” to add, swipe to delete expenses


