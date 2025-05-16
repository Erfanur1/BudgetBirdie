import SwiftUI
import UserNotifications
import CoreData


struct EnhancedSettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationTime") private var notificationTime = Date()
    @AppStorage("budgetRemindersEnabled") private var budgetRemindersEnabled = false
    @AppStorage("monthlyBudget") private var monthlyBudget = ""
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    
   
    @AppStorage("colorTheme") private var colorTheme = "Blue"
    let themes = ["Blue", "Purple", "Green", "Orange"]
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                BudgetBirdieTheme.backgroundBlue
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Text("Settings")
                                .font(BudgetBirdieTheme.titleFont)
                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                            
                            Spacer()
                        }
                        .padding()
                        
                        // Notifications Section
                        settingsCard(
                            title: "Notifications",
                            icon: "bell.fill",
                            content: {
                                VStack(spacing: 15) {
                                    Toggle("Enable Daily Reminders", isOn: $notificationsEnabled)
                                        .onValueChange(of: notificationsEnabled) { newValue in
                                            if newValue {
                                                requestNotificationPermission()
                                            } else {
                                                cancelScheduledNotifications()
                                            }
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: BudgetBirdieTheme.primaryBlue))
                                    
                                    if notificationsEnabled {
                                        Divider()
                                        
                                        VStack(alignment: .leading, spacing: 10) {
                                            Text("Reminder Time")
                                                .font(.headline)
                                            
                                            DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                                                .datePickerStyle(WheelDatePickerStyle())
                                                .labelsHidden()
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .onValueChange(of: notificationTime) { _ in
                                                    if notificationsEnabled {
                                                        scheduleNotifications()
                                                    }
                                                }
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                            }
                        )
                        
                        // Budget Settings
                        settingsCard(
                            title: "Budget",
                            icon: "dollarsign.circle.fill",
                            content: {
                                VStack(spacing: 15) {
                                    Toggle("Enable Budget Reminders", isOn: $budgetRemindersEnabled)
                                        .toggleStyle(SwitchToggleStyle(tint: BudgetBirdieTheme.primaryBlue))
                                    
                                    Divider()
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Monthly Budget")
                                            .font(.headline)
                                        
                                        HStack {
                                            Text("$")
                                                .font(.title3)
                                            
                                            TextField("0.00", text: $monthlyBudget)
                                                .keyboardType(.decimalPad)
                                                .font(.title3)
                                                .padding(10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color(.systemGray6))
                                                )
                                        }
                                    }
                                }
                            }
                        )
                        
                        // Data Management
                        settingsCard(
                            title: "Data Management",
                            icon: "folder.fill",
                            content: {
                                VStack(spacing: 15) {
                                    Button(action: {
                                        showingExportSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.up.doc.fill")
                                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                            Text("Export Data")
                                                .fontWeight(.medium)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white)
                                        )
                                    }
                                    
                                    Button(action: {
                                        showingImportSheet = true
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.down.doc.fill")
                                                .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                            Text("Import Data")
                                                .fontWeight(.medium)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white)
                                        )
                                    }
                                    
                                    Button(action: {
                                        showingAlert = true
                                    }) {
                                        HStack {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                            Text("Clear All Data")
                                                .fontWeight(.medium)
                                                .foregroundColor(.red)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white)
                                        )
                                    }
                                }
                            }
                        )
                        
                        // About Section
                        settingsCard(
                            title: "About",
                            icon: "info.circle.fill",
                            content: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "bird.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                        
                                        VStack(alignment: .leading) {
                                            Text("BudgetBirdie")
                                                .font(.title2.bold())
                                            Text("Version 1.0")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Divider()
                                        .padding(.vertical, 5)
                                    
                                    Text("Take Flight With Your Finances!")
                                        .font(.headline)
                                        .foregroundColor(BudgetBirdieTheme.primaryBlue)
                                    
                                    Text("BudgetBirdie helps you track your expenses easily and visualize your spending habits to make better financial decisions.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                    
                                    // Social media or link buttons could go here
                                    HStack {
                                        Spacer()
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                        Spacer()
                                    }
                                    .padding(.top)
                                }
                            }
                        )
                        
                        // Space at bottom for comfort
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingExportSheet) {
                if #available(iOS 16.0, *) {
                    ExportView()
                } else {
                    LegacyExportView()
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Clear All Data"),
                    message: Text("Are you sure you want to clear all expense data? This action cannot be undone."),
                    primaryButton: .destructive(Text("Clear")) {
                        clearAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // Helper function to create consistent settings cards
    private func settingsCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
                
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(BudgetBirdieTheme.primaryBlue)
            }
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotifications()
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotifications() {
        cancelScheduledNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "BudgetBirdie Reminder"
        content.body = "Don't forget to log your expenses for today!"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "budgetBirdieReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["budgetBirdieReminder"])
    }
    
    private func clearAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
            try viewContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}
