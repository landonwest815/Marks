import SwiftData
import SwiftUI

// VIEW: Just the UI

struct TermsView: View {
    
    // Swift Data Context + Models
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Term.id) var terms: [Term]
    @Query var courses: [Course]
    @Query var groups: [AssignmentGroup]
    @Query var assignments: [Assignment]
    
    // View Model
    @StateObject private var viewModel = ViewModel()
    
    // UI Change Triggers
    @State private var refreshList = false
    @State private var isShowingAddTermSheet = false
    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 28)!]
    }

    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 0) {
                
                // Stats
                HStack(spacing: 9) {
                    VStack {
                        Text(terms.count.description)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .contentTransition(.numericText(value: Double(terms.count)))
                        Text("Terms")
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 66)
                    
                    VStack {
                        Text(courses.count.description)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .contentTransition(.numericText(value: Double(courses.count)))
                        Text("Courses")
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 66)
                    
                    VStack {
                        Text(groups.count.description)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .contentTransition(.numericText(value: Double(groups.count)))
                        Text("Groups")
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 66)
                    
                    VStack {
                        Text(assignments.count.description)
                            .fontWeight(.semibold)
                            .font(.title2)
                            .contentTransition(.numericText(value: Double(assignments.count)))
                        Text("Assignments")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)

                // Term Links
                List {
                    ForEach(terms) { term in
                        NavigationLink(destination: CoursesView(term: term)) {
                            HStack(spacing: 20) {
                                Text(String(term.id))
                                    .fontWeight(.semibold)
                                Text(term.name ?? "Unnamed Term")                                .lineLimit(1)
                                    .fontWeight(.light)
                            }
                        }
                        
                    }
                    // Slide to Delete
                    .onDelete { offsets in
                        viewModel.deleteTerm(terms: terms, at: offsets, modelContext: modelContext)
                        refreshList.toggle()  // Trigger a refresh
                    }
                }
                .id(refreshList)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await pullData()
                    refreshList.toggle()
                }
            }
            .fontDesign(.serif)
            .preferredColorScheme(.dark)
            .background(.ultraThinMaterial)
            .navigationTitle("Terms")
            .toolbar {
                
                // Icon Image
                ToolbarItem(placement: .topBarLeading) {
                    Image("AppIconImageLight")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                // Delete all the Terms
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewModel.eraseAllTerms(terms: terms, modelContext: modelContext)
                        refreshList.toggle()
                    }) {
                        Label("Erase All", systemImage: "trash")
                    }
                }
                
                // Create a new Term (present the sheet)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isShowingAddTermSheet.toggle() }) {
                        Label("Add Term", systemImage: "plus")
                    }
                }
                
            }
            .sheet(isPresented: $isShowingAddTermSheet) {
                AddTermSheet(
                    newTermID: $viewModel.newTermID,
                    newTermName: $viewModel.newTermName,
                    onSave: {
                        viewModel.addNewTerm(modelContext: modelContext)
                        refreshList.toggle()  // Trigger a refresh
                    }
                )
            }
        }
    }
    
    func pullData() async {
        if let newCourses = try? await viewModel.fetchCourses() {
            for course in newCourses {
                if true/*course.term?.id ?? 0 > 1390*/ {
                    
                    await viewModel.insertCourse(course: course, terms: terms, modelContext: modelContext)
                                        
                    if let newGroups = try? await viewModel.fetchGroups(courseId: course.id) {
                        for group in newGroups {
                            if let course = courses.first(where: { $0.id == course.id }) {
                                await viewModel.insertGroup(group: group, course: course, modelContext: modelContext)
                            }
                        }
                        
                        if let newAssignments = try? await viewModel.fetchAssignments(courseId: course.id) {
                            for assignment in newAssignments {
                                if let group = groups.first(where: { $0.id == assignment.assignment_group_id }) {
                                    await viewModel.insertAssignment(assignment: assignment, group: group, modelContext: modelContext)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}





// SHEET POP UP: Adding Term

struct AddTermSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newTermID: String
    @Binding var newTermName: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Term Details")) {
                    TextField("ID (Integer)", text: $newTermID)
                        .keyboardType(.numberPad)
                    TextField("Name", text: $newTermName)
                }
            }
            .navigationTitle("Add New Term")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}




// PREVIEW WINDOW: Messing around with the running app

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Term.self, configurations: config)
 
    return TermsView()
        .modelContainer(container)
}




// VIEW MODEL: Logic Processing and Data Management

extension TermsView {
    class ViewModel: ObservableObject {
        @Published var newTermID: String = ""
        @Published var newTermName: String = ""
        let canvasAPI = CanvasAPI(token: "2~JGcTJFzKBaUDDwVcHMAAFuPy4ThYnhKWL72fCHAcMGZhYMmEyGLGUJnJkhNcU8zz")
        
        func addNewTerm(modelContext: ModelContext) {
            guard let id = Int(newTermID) else {
                print("Invalid ID")
                return
            }
            
            let newTerm = Term(
                id: id,
                name: newTermName.isEmpty ? "Unnamed Term" : newTermName,
                startAt: "2024-01-01",
                endAt: "2024-06-01"
            )
            
            modelContext.insert(newTerm)
            withAnimation {
                try? modelContext.save()
            }
            resetNewTermFields() // Reset fields after adding
        }

        func resetNewTermFields() {
            newTermID = ""
            newTermName = ""
        }

        func eraseAllTerms(terms: [Term], modelContext: ModelContext) {
            terms.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }

        func deleteTerm(terms: [Term], at offsets: IndexSet, modelContext: ModelContext) {
            offsets.map { terms[$0] }.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }
        
        @MainActor
        func fetchCourses() async throws -> [CourseDTO] {
            return try await canvasAPI.fetchCourses()
        }
        
        @MainActor
        func insertCourse(course: CourseDTO, terms: [Term], modelContext: ModelContext) async {
            if let term = course.term {
                if let existingTerm = terms.first(where: { $0.id == term.id }) {
                    // Reuse the existing term
                    let newCourse = Course(id: course.id, name: course.name)
                    newCourse.term = existingTerm
                    existingTerm.courses.append(newCourse)
                } else {
                    // Insert a new term if it doesn’t exist
                    let newTerm = Term(id: term.id, name: term.name)
                    modelContext.insert(newTerm)
                    
                    // Add and link the new course to the new term
                    let newCourse = Course(id: course.id, name: course.name)
                    newCourse.term = newTerm
                    newTerm.courses.append(newCourse)
                }
            }
            
            // Save after processing each course
            try? modelContext.save()
        }
        
        @MainActor
        func fetchGroups(courseId: Int) async throws -> [AssignmentGroupDTO] {
            return try await canvasAPI.fetchGroups(courseId: courseId)
        }
        
        @MainActor
        func insertGroup(group: AssignmentGroupDTO, course: Course, modelContext: ModelContext) async {
        
            let newGroup = AssignmentGroup(id: group.id, name: group.name, weight: group.weight)
            newGroup.course = course
            course.assignmentGroups.append(newGroup)
            
            // Save after processing each course
            try? modelContext.save()
        }
        
        @MainActor
        func fetchAssignments(courseId: Int) async throws -> [AssignmentDTO] {
            return try await canvasAPI.fetchAssignments(courseId: courseId)
        }
        
        @MainActor
        func insertAssignment(assignment: AssignmentDTO, group: AssignmentGroup, modelContext: ModelContext) async {
        
            let newAssignment = Assignment(id: assignment.id, name: assignment.name)
            newAssignment.assignmentGroup = group
            group.assignments.append(newAssignment)
            
            // Save after processing each course
            try? modelContext.save()
        }
    }
}
