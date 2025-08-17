# Pencatatan

Pencatatan is a personal finance application for iOS that helps you track your income, expenses, and budgets.

## Features

*   **Transaction Tracking:** Record your income, expenses, and transfers between accounts.
*   **Budgeting:** Set monthly budgets for different spending categories.
*   **Categorization:** Organize your transactions into custom categories.
*   **Payment Methods:** Manage your different payment methods (e.g., cash, credit card, bank account).
*   **Reporting:** View summaries of your income, expenses, and budget adherence.

## Getting Started

To build and run the project, you will need Xcode and the Swift toolchain.

1.  Clone the repository:

    ```bash
    git clone https://github.com/Reza-Project-ADA/Pencatatan.git
    ```

2.  Install Tuist using Brew:

    ```bash
    brew install tuist

3.  Open the project in Xcode:

    ```bash
    tuist install && tuist generate
    ```
4.  Build and run the app on the simulator or a physical device.

## Technologies Used

*   **SwiftUI:** The user interface is built with Apple's modern declarative framework.
*   **Core Data:** Data is persisted locally using Core Data.
*   **Tuist:** The project is structured and managed using Tuist.    

## To-Do List

### Record
*   ~Income & expenses can't be added~
*   Resolve app crash that occurs on refresh 
```List failed to visit cell content, returning an empty cell. - SwiftUICore/Logging.swift:84 - please file a bug report.```
```(Thread 1: Fatal error: 'try!' expression unexpectedly raised an error: SwiftUI.AnyNavigationPath.Error.comparisonTypeMismatch).```
*   ~Crash on related to the numpad appearing.~ ```(Thread 1: signal SIGTERM)```

### Budgeting

*   Set the total number of initial budgets on the main budget screen.
*   Format currency with commas or points in the budget initialization/addition screen.
*   Implement editing functionality for existing budgets.
*   Addition of duplicate budget categories is blocked, should it still be able to be done?
*   Move the "Add Budget Category" functionality from "Settings" to the "Budgeting" section.

### Settings

*   Correct the typo in the item category addition section. (Cateogory)
*   Clarify the purpose of the "Profile" and "Friends" sections.
*   Explain the functionality of the "Payment Method" section.

### Potential Features

*   Refactor the app to display data on a monthly basis instead of each with different month?
*   Evaluate the efficiency of scanning receipts versus manual typing. (just add both feature?)
*   Implement a feature to add expenses by sharing photos from other apps.

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or bug reports, please open an issue or submit a pull request.
