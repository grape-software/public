# Grape .NET Copilot Instructions

You are an expert in .NET development and microservices architecture, providing best practices and instructions for coding microservices repositories in .NET based on Grape Software standards.
This prompts serves as a guideline for developers to ensure the use of Grape Standards for consistency, maintainability, and quality across microservices projects.
It includes instructions on repository structure, development environment setup, configuration management, logging, and deployment practices.
You should follow these guidelines when creating or contributing to microservices repositories.

## General Guidelines

- Follow consistent naming conventions for variables, methods, classes, and files. Use names that are descriptive and meaningful.
- Write clean and readable code. Use proper indentation, spacing, and line breaks to enhance code readability.
- Comment your code where necessary to explain complex logic or decisions. Avoid redundant comments that do not add value.
- Adhere to the DRY (Don't Repeat Yourself) principle. Avoid code duplication by creating reusable functions or modules.
- Use version control systems (e.g., Git) effectively. Commit changes with clear and concise messages.
- Use linting tools to enforce coding standards and identify potential issues early in the development process.

## Instructions for coding microservices repositories in .NET

- Use Grape Snippets or Reference components to generate CRUD controllers to ensure consistency.
- Use properties instead of public fields for data encapsulation.
- Implement exception handling to manage errors gracefully. Try to reuse exception types where applicable. Theres is a common method to handle exceptions in a centralized manner on BaseController called HandleException that receive an exception and return the appropriate response with the correct status code. This method should be used in all controllers to handle exceptions and ensure consistent error handling across the application. If you need to handle specific exceptions differently, you can create custom exception types and handle them in custom controller. Ensure all code that returns an Exception with a message is throwing a BussinessException Class.
- Utilize LINQ for data manipulation and querying collections.
- Follow SOLID principles for object-oriented design to create maintainable and scalable code.
- Only use int for primary keys when Entity is a transactional entity. For reference entities, consider using Guid or string types.
- Using entity framework, prefer using Data Annotations for simple configurations and Fluent API for complex configurations.
- To simplify code, if block that only has a line of code inside, consider removing the braces. Also include blocks with one single line and with an else statement.
- Blank lines should be avoided. Remove unnecessary blank lines to maintain code compactness. Only exception is when method have more than 100 lines of code. And then, blank lines can be used to separate logical sections within the method to enhance readability.
- Minimize the creation of variables. Only create variables when necessary to improve code clarity or performance. Variables names should be descriptive and meaningful. Remove innecessary variables that do not contribute to code clarity or was repetitive.
- Using in files only should be used when necessary. Remove unneeded usings to keep the code clean and avoid potential conflicts. Check warning "Using directive is unnecessary" from compiler and remove them.
- After using add a whitespace line to separate usings from the rest of the code.
- Name of methods that was used to return a value should start with "Get", for example: GetUserById, GetPaymentDetails, etc.
- Name of methods used to validate something should start with "Check" or "Is", for example: CheckUserPermissions, IsPaymentValid, etc.
- Name of methods used to build or create an object should start with "Create" for example: CreateInvoice, CreateUserSession, etc.
- Name of methods used to update an object should start with "Update", for example: UpdateOrderStatus, UpdateUserProfile, etc.
- Name of methods used to delete an object should start with "Delete", for example: DeleteCustomerRecord, DeleteTemporaryFiles, etc.
- Asynchronous methods should have the "Async" suffix in their names, for example: FetchDataAsync, SaveChangesAsync, etc.
- Avoid creating DTO object for partial representation of an entity. Instead, use the entity directly and discard unneded properties in business logic or mapping layers. This is because when calling services from endpoint with REST you only call it with properties that was needed and binding resolve the mapping.
- When working with Entity Framework, prefer using asynchronous methods (e.g., ToListAsync, FirstOrDefaultAsync) to improve application responsiveness and scalability. And also use AsNoTracking() when the entities are only for read-only operations to improve performance. An avoid writing AsTracking() because is the default behavior.
