import SwiftData
import SwiftUI

// VIEW: Just the UI

struct CoursesView: View {
    
    // Swift Data Context + Models
    @Environment(\.modelContext) var modelContext
    var term: Term
    
    // View Model
    @StateObject private var viewModel = ViewModel()
    
    // UI Change Triggers
    @State private var refreshList = false
    @State private var isShowingSheet = false
    
    init(term: Term) {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 28)!]
        self.term = term
    }
    
    var body: some View {
            
        VStack(spacing: 0) {

            // Term Links
            List {
                ForEach(term.courses) { course in
                    NavigationLink(destination: AssignmentGroupsView(course: course)) {
                        HStack(spacing: 20) {
                            Text(String(course.id))
                                .fontWeight(.semibold)
                            Text(course.name ?? "Unnamed Course")                                .lineLimit(1)
                                .fontWeight(.light)
                        }
                    }
                }
                // Slide to Delete
                .onDelete { offsets in
                    viewModel.deleteCourse(courses: term.courses, at: offsets, modelContext: modelContext)
                    refreshList.toggle()  // Trigger a refresh
                }
            }
            .id(refreshList)
            .scrollContentBackground(.hidden)
        }
        .fontDesign(.serif)
        .preferredColorScheme(.dark)
        .background(.ultraThinMaterial)
        .navigationTitle(term.name ?? "Courses")
        .toolbar {
            
            // Delete all the Courses
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.eraseAllCourses(courses: term.courses, modelContext: modelContext)
                    refreshList.toggle()
                }) {
                    Label("Erase All", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Create a new Course (present the sheet)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isShowingSheet.toggle() }) {
                    Label("Add Course", systemImage: "plus")
                }
            }
            
        }
        .sheet(isPresented: $isShowingSheet) {
            AddCourseSheet(
                newCourseID: $viewModel.newCourseID,
                newCourseName: $viewModel.newCourseName,
                onSave: {
                    viewModel.addNewCourse(modelContext: modelContext, term: term)
                    refreshList.toggle()  // Trigger a refresh
                }
            )
        }
    }
}





// SHEET POP UP: Adding Course

struct AddCourseSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var newCourseID: String
    @Binding var newCourseName: String
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Course Details")) {
                    TextField("ID (Integer)", text: $newCourseID)
                        .keyboardType(.numberPad)
                    TextField("Name", text: $newCourseName)
                }
            }
            .navigationTitle("Add New Coursse")
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

extension CoursesView {
    class ViewModel: ObservableObject {
        @Published var newCourseID: String = ""
        @Published var newCourseName: String = ""
        
        func addNewCourse(modelContext: ModelContext, term: Term) {
            guard let id = Int(newCourseID) else {
                print("Invalid ID")
                return
            }
            
            let newCourse = Course(
                id: id,
                name: newCourseName.isEmpty ? "Unnamed Course" : newCourseName,
                accountId: nil,
                uuid: nil,
                courseCode: nil,
                enrollmentTermId: nil
            )
            newCourse.term = term  // Link the course to the current term
            term.courses.append(newCourse)
            withAnimation {
                try? modelContext.save()
            }
            resetNewCourseFields() // Reset fields after adding
        }

        func resetNewCourseFields() {
            newCourseID = ""
            newCourseName = ""
        }

        func eraseAllCourses(courses: [Course], modelContext: ModelContext) {
            courses.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }

        func deleteCourse(courses: [Course], at offsets: IndexSet, modelContext: ModelContext) {
            offsets.map { courses[$0] }.forEach { modelContext.delete($0) }
            withAnimation {
                try? modelContext.save()
            }
        }
    }
}
