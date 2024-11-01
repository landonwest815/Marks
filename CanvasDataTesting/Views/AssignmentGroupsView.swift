import SwiftData
import SwiftUI

// VIEW: Just the UI

struct AssignmentGroupsView: View {
    
    // Swift Data Context + Models
    @Environment(\.modelContext) var modelContext
    var course: Course
    
    // View Model
    @StateObject private var viewModel = ViewModel()
    
    // UI Change Triggers
    @State private var refreshList = false
    @State private var isShowingSheet = false
    
    init(course: Course) {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 28)!]
        self.course = course
    }
    
    var body: some View {
            
        VStack(spacing: 0) {

            // Group Links
            List {
                ForEach(course.assignmentGroups) { group in
                    NavigationLink(destination: AssignmentsView(group: group)) {
                        HStack(spacing: 20) {
                            Text(String(group.id))
                                .fontWeight(.semibold)
                            Text(group.name ?? "Unnamed Group")
                                .lineLimit(1)
                                .fontWeight(.light)
                        }
                    }
                }
                // Slide to Delete
                .onDelete { offsets in
                    viewModel.deleteGroup(groups: course.assignmentGroups, at: offsets, modelContext: modelContext)
                    refreshList.toggle()  // Trigger a refresh
                }
            }
            .id(refreshList)
            .scrollContentBackground(.hidden)
        }
        .fontDesign(.serif)
        .preferredColorScheme(.dark)
        .background(.ultraThinMaterial)
        .navigationTitle("Assignment Groups")
        .toolbar {
            
            // Delete all the Groups
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.eraseAllGroups(groups: course.assignmentGroups, modelContext: modelContext)
                    refreshList.toggle()
                }) {
                    Label("Erase All", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Create a new Group (present the sheet)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isShowingSheet.toggle() }) {
                    Label("Add Group", systemImage: "plus")
                }
            }
            
        }
        .sheet(isPresented: $isShowingSheet) {
            AddGroupSheet(
                newGroupID: $viewModel.newGroupID,
                newGroupName: $viewModel.newGroupName,
                onSave: {
                    viewModel.addNewGroup(modelContext: modelContext, course: course)
                    refreshList.toggle()  // Trigger a refresh
                }
            )
        }
    }
}





// SHEET POP UP: Adding Course

struct AddGroupSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newGroupID: String
    @Binding var newGroupName: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Group Details")) {
                    TextField("ID (Integer)", text: $newGroupID)
                        .keyboardType(.numberPad)
                    TextField("Name", text: $newGroupName)
                }
            }
            .navigationTitle("Add New Groups")
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

extension AssignmentGroupsView {
    class ViewModel: ObservableObject {
        @Published var newGroupID: String = ""
        @Published var newGroupName: String = ""
        
        func addNewGroup(modelContext: ModelContext, course: Course) {
            guard let id = Int(newGroupID) else {
                print("Invalid ID")
                return
            }
            
            let newGroup = AssignmentGroup(
                id: id,
                name: newGroupName.isEmpty ? "Unnamed Group" : newGroupName,
                weight: 20.0
            )
            newGroup.course = course  // Link the group to the current course
            course.assignmentGroups.append(newGroup)
            withAnimation {
                try? modelContext.save()
            }
            resetNewGroupFields() // Reset fields after adding
        }

        func resetNewGroupFields() {
            newGroupID = ""
            newGroupName = ""
        }

        func eraseAllGroups(groups: [AssignmentGroup], modelContext: ModelContext) {
            groups.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }

        func deleteGroup(groups: [AssignmentGroup], at offsets: IndexSet, modelContext: ModelContext) {
            offsets.map { groups[$0] }.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }
    }
}
