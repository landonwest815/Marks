import SwiftData
import SwiftUI

// VIEW: Just the UI

struct AssignmentsView: View {
    
    // Swift Data Context + Models
    @Environment(\.modelContext) var modelContext
    var group: AssignmentGroup
    
    // View Model
    @StateObject private var viewModel = ViewModel()
    
    // UI Change Triggers
    @State private var refreshList = false
    @State private var isShowingSheet = false
    
    init(group: AssignmentGroup) {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 28)!]
        self.group = group
    }
    
    var body: some View {
            
        VStack(spacing: 0) {

            // assignment Links
            List {
                ForEach(group.assignments) { assignment in
                    HStack(spacing: 20) {
                        Text(String(assignment.id))
                            .fontWeight(.semibold)
                        Text(assignment.name ?? "Unnamed assignment")                                .lineLimit(1)
                            .fontWeight(.light)
                    }
                }
                // Slide to Delete
                .onDelete { offsets in
                    viewModel.deleteAssignment(assignments: group.assignments, at: offsets, modelContext: modelContext)
                    refreshList.toggle()  // Trigger a refresh
                }
            }
            .id(refreshList)
            .scrollContentBackground(.hidden)
        }
        .fontDesign(.serif)
        .preferredColorScheme(.dark)
        .background(.ultraThinMaterial)
        .navigationTitle("Assignments")
        .toolbar {
            
            // Delete all the assignments
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.eraseAllAssignments(assignments: group.assignments, modelContext: modelContext)
                    refreshList.toggle()
                }) {
                    Label("Erase All", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Create a new assignment (present the sheet)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isShowingSheet.toggle() }) {
                    Label("Add Assignment", systemImage: "plus")
                }
            }
            
        }
        .sheet(isPresented: $isShowingSheet) {
            AddAssignmentSheet(
                newAssignmentID: $viewModel.newAssignmentID,
                newAssignmentName: $viewModel.newAssignmentName,
                onSave: {
                    viewModel.addNewAssignment(modelContext: modelContext, group: group)
                    refreshList.toggle()  // Trigger a refresh
                }
            )
        }
    }
}





// SHEET POP UP: Adding Course

struct AddAssignmentSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newAssignmentID: String
    @Binding var newAssignmentName: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("ID (Integer)", text: $newAssignmentID)
                        .keyboardType(.numberPad)
                    TextField("Name", text: $newAssignmentName)
                }
            }
            .navigationTitle("Add New Assignments")
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

extension AssignmentsView {
    class ViewModel: ObservableObject {
        @Published var newAssignmentID: String = ""
        @Published var newAssignmentName: String = ""
        
        func addNewAssignment(modelContext: ModelContext, group: AssignmentGroup) {
            guard let id = Int(newAssignmentID) else {
                print("Invalid ID")
                return
            }
            
            let newAssignment = Assignment(
                id: id,
                name: newAssignmentName.isEmpty ? "Unnamed assignment" : newAssignmentName,
                assignmentDescription: nil,
                dueAt: nil,
                pointsPossible: nil,
                uuid: nil
            )
            
            newAssignment.assignmentGroup = group  // Link the assignment to the current course
            group.assignments.append(newAssignment)
            withAnimation {
                try? modelContext.save()
            }
            resetNewAssignmentFields() // Reset fields after adding
        }

        func resetNewAssignmentFields() {
            newAssignmentID = ""
            newAssignmentName = ""
        }

        func eraseAllAssignments(assignments: [Assignment], modelContext: ModelContext) {
            assignments.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }

        func deleteAssignment(assignments: [Assignment], at offsets: IndexSet, modelContext: ModelContext) {
            offsets.map { assignments[$0] }.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }
    }
}
